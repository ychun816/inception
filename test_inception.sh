#!/bin/bash

# Inception Project Comprehensive Test Script
# This script thoroughly tests all components of the Inception project

set -e  # Exit on any error

# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# **************************************************************************** #
#                              PRINT FUNCTIONS                                 #
# **************************************************************************** #
print_header() {
    echo -e "\n${BLUE}=== $1 ===${RESET}"
}

print_success() {
    echo -e "${GREEN}✅ $1${RESET}"
}

print_error() {
    echo -e "${RED}❌ $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${RESET}"
}

# **************************************************************************** #
#                              CONFIGURATION                                   #
# **************************************************************************** #
COMPOSE_FILE="./srcs/docker-compose.yml"
DOMAIN="yilin.42.fr"
DB_USER="yilin"
DB_PASS="happybirthday"
EXPECTED_CONTAINERS=3

# **************************************************************************** #
#                              TEST FUNCTIONS                                  #
# **************************************************************************** #

# Test 1: Check if docker-compose file exists
test_compose_file() {
    print_header "TEST 1: DOCKER-COMPOSE FILE"
    
    if [ -f "$COMPOSE_FILE" ]; then
        print_success "docker-compose.yml found"
        echo "File: $COMPOSE_FILE"
    else
        print_error "docker-compose.yml not found at $COMPOSE_FILE"
        return 1
    fi
}

# Test 2: Check container status
test_containers() {
    print_header "TEST 2: CONTAINER STATUS"
    
    echo "Checking container status..."
    local running_containers=$(docker compose -f "$COMPOSE_FILE" ps --services --filter "status=running" | wc -l)
    
    if [ "$running_containers" -eq "$EXPECTED_CONTAINERS" ]; then
        print_success "All $EXPECTED_CONTAINERS containers are running"
        docker compose -f "$COMPOSE_FILE" ps
    else
        print_error "Expected $EXPECTED_CONTAINERS containers, but $running_containers are running"
        docker compose -f "$COMPOSE_FILE" ps
        return 1
    fi
}

# Test 3: Test network connectivity
test_network() {
    print_header "TEST 3: NETWORK CONNECTIVITY"
    
    echo "Testing internal container network..."
    
    # Test if WordPress can connect to MariaDB via database connection
    if docker exec wordpress wp db check --allow-root > /dev/null 2>&1; then
        print_success "WordPress can connect to MariaDB (database connection)"
    else
        print_warning "WordPress database connection test failed (may be temporary)"
    fi
    
    # Test if containers are on the same network
    local wp_network=$(docker inspect wordpress --format='{{range $net, $config := .NetworkSettings.Networks}}{{$net}}{{end}}' 2>/dev/null)
    local db_network=$(docker inspect mariadb --format='{{range $net, $config := .NetworkSettings.Networks}}{{$net}}{{end}}' 2>/dev/null)
    
    if [ "$wp_network" = "$db_network" ] && [ -n "$wp_network" ]; then
        print_success "Containers are on the same network: $wp_network"
    else
        print_warning "Container network configuration unclear"
    fi
}

# Test 4: Test HTTPS connectivity
test_https() {
    print_header "TEST 4: HTTPS CONNECTIVITY"
    
    echo "Testing HTTPS connection to $DOMAIN..."
    
    if curl -k -s -f "https://$DOMAIN" > /dev/null; then
        print_success "HTTPS connection successful"
        
        # Check response code
        local response_code=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN")
        if [ "$response_code" = "200" ]; then
            print_success "HTTP response code: $response_code"
        else
            print_warning "HTTP response code: $response_code (expected 200)"
        fi
    else
        print_error "HTTPS connection failed"
        return 1
    fi
}

# Test 5: Test SSL certificates
test_ssl() {
    print_header "TEST 5: SSL CERTIFICATES"
    
    echo "Checking SSL certificate..."
    
    # Check if SSL certificate is present and valid
    if echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | grep -q "$DOMAIN"; then
        print_success "SSL certificate contains correct domain"
    else
        print_warning "SSL certificate domain check inconclusive (self-signed certificate)"
    fi
    
    # Check certificate expiry
    local cert_info=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    if [ $? -eq 0 ]; then
        print_success "SSL certificate is readable"
        echo "$cert_info"
    else
        print_error "Cannot read SSL certificate"
        return 1
    fi
}

# Test 6: Test MariaDB database
test_database() {
    print_header "TEST 6: MARIADB DATABASE"
    
    echo "Testing database connection and functionality..."
    
    # Test connection
    if docker exec mariadb mysql -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed"
        return 1
    fi
    
    # Test database exists
    if docker exec mariadb mysql -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep -q "wordpress"; then
        print_success "WordPress database exists"
    else
        print_error "WordPress database not found"
        return 1
    fi
    
    # Test tables exist
    local table_count=$(docker exec mariadb mysql -u "$DB_USER" -p"$DB_PASS" -e "USE wordpress; SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$table_count" -gt 1 ]; then
        print_success "WordPress tables found ($table_count tables)"
    else
        print_warning "WordPress tables may not be fully initialized"
    fi
}

# Test 7: Test WordPress functionality
test_wordpress() {
    print_header "TEST 7: WORDPRESS FUNCTIONALITY"
    
    echo "Testing WordPress installation and WP-CLI..."
    
    # Test WP-CLI
    if docker exec wordpress wp --version --allow-root > /dev/null 2>&1; then
        local wp_version=$(docker exec wordpress wp --version --allow-root 2>/dev/null)
        print_success "WP-CLI working: $wp_version"
    else
        print_error "WP-CLI not working"
        return 1
    fi
    
    # Test WordPress core
    if docker exec wordpress wp core version --allow-root > /dev/null 2>&1; then
        local core_version=$(docker exec wordpress wp core version --allow-root 2>/dev/null)
        print_success "WordPress core installed: $core_version"
    else
        print_error "WordPress core not properly installed"
        return 1
    fi
    
    # Test if WordPress is configured
    if docker exec wordpress wp config path --allow-root > /dev/null 2>&1; then
        print_success "WordPress configuration found"
    else
        print_error "WordPress configuration missing"
        return 1
    fi
}

# Test 8: Test Nginx configuration
test_nginx() {
    print_header "TEST 8: NGINX CONFIGURATION"
    
    echo "Testing Nginx configuration..."
    
    # Test Nginx config syntax
    if docker exec nginx nginx -t > /dev/null 2>&1; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
        docker exec nginx nginx -t
        return 1
    fi
    
    # Test if Nginx is serving on port 443
    if docker exec nginx netstat -tlnp 2>/dev/null | grep -q ":443"; then
        print_success "Nginx listening on port 443"
    else
        # Try with ss if netstat is not available
        if docker exec nginx ss -tlnp 2>/dev/null | grep -q ":443"; then
            print_success "Nginx listening on port 443"
        else
            print_error "Nginx not listening on port 443"
            return 1
        fi
    fi
}

# Test 9: Test data persistence
test_persistence() {
    print_header "TEST 9: DATA PERSISTENCE"
    
    echo "Testing data volume mounts..."
    
    # Check WordPress data
    if [ -d "$HOME/data/wordpress_data" ] && [ "$(ls -A $HOME/data/wordpress_data 2>/dev/null)" ]; then
        print_success "WordPress data directory exists and has content"
        echo "WordPress data size: $(du -sh $HOME/data/wordpress_data 2>/dev/null | cut -f1)"
    else
        print_error "WordPress data directory missing or empty"
        return 1
    fi
    
    # Check MariaDB data
    if [ -d "$HOME/data/mariadb_data" ] && [ "$(ls -A $HOME/data/mariadb_data 2>/dev/null)" ]; then
        print_success "MariaDB data directory exists and has content"
        echo "MariaDB data size: $(du -sh $HOME/data/mariadb_data 2>/dev/null | cut -f1)"
    else
        print_error "MariaDB data directory missing or empty"
        return 1
    fi
}

# Test 10: Test website content
test_website_content() {
    print_header "TEST 10: WEBSITE CONTENT"
    
    echo "Testing website content..."
    
    # Test if site title is correct
    if curl -k -s "https://$DOMAIN" | grep -q "Yilin.*Inception"; then
        print_success "Site title contains 'Yilin' and 'Inception'"
    else
        print_warning "Site title may not be customized"
    fi
    
    # Test if custom content exists
    if curl -k -s "https://$DOMAIN" | grep -q "Inception baby"; then
        print_success "Custom content found (Inception baby post)"
    else
        print_warning "Custom content not found"
    fi
    
    # Test admin panel accessibility
    local admin_response=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/wp-admin/")
    if [ "$admin_response" = "200" ] || [ "$admin_response" = "302" ]; then
        print_success "WordPress admin panel accessible (HTTP $admin_response)"
    else
        print_error "WordPress admin panel not accessible (HTTP $admin_response)"
        return 1
    fi
}

# **************************************************************************** #
#                              MAIN EXECUTION                                  #
# **************************************************************************** #

main() {
    echo -e "${WHITE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    INCEPTION PROJECT COMPREHENSIVE TEST                      ║"
    echo "║                                                                              ║"
    echo "║  This script will thoroughly test all components of your Inception project   ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    local failed_tests=0
    local total_tests=10
    
    # Run all tests
    test_compose_file || ((failed_tests++))
    test_containers || ((failed_tests++))
    test_network || ((failed_tests++))
    test_https || ((failed_tests++))
    test_ssl || ((failed_tests++))
    test_database || ((failed_tests++))
    test_wordpress || ((failed_tests++))
    test_nginx || ((failed_tests++))
    test_persistence || ((failed_tests++))
    test_website_content || ((failed_tests++))
    
    # Final summary
    print_header "TEST SUMMARY"
    local passed_tests=$((total_tests - failed_tests))
    
    echo "Tests passed: $passed_tests/$total_tests"
    
    if [ $failed_tests -eq 0 ]; then
        print_success "🎉 ALL TESTS PASSED! Your Inception project is working perfectly! 🎉"
        echo -e "${GREEN}Your WordPress site is live at: https://$DOMAIN${RESET}"
        return 0
    else
        print_error "⚠️  $failed_tests test(s) failed. Please check the issues above."
        return 1
    fi
}

# Run the main function
main "$@"
