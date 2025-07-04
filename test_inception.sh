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

# Test 4: Test HTTPS connectivity and HTTP blocking
test_https() {
    print_header "TEST 4: HTTPS CONNECTIVITY & HTTP BLOCKING"
    
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
    
    echo "Testing HTTP access is blocked..."
    # Test that HTTP is not accessible (should fail or redirect)
    local http_response=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" 2>/dev/null || echo "000")
    if [ "$http_response" = "000" ] || [ "$http_response" = "403" ] || [ "$http_response" = "404" ]; then
        print_success "HTTP access properly blocked (response: $http_response)"
    elif [ "$http_response" = "301" ] || [ "$http_response" = "302" ]; then
        print_success "HTTP redirects to HTTPS (response: $http_response)"
    else
        print_error "HTTP access should be blocked but got response: $http_response"
        return 1
    fi
}

# Test 5: Test WordPress Installation Status
test_wordpress_installation() {
    print_header "TEST 5: WORDPRESS INSTALLATION STATUS"
    
    echo "Checking WordPress installation status..."
    
    # Check if WordPress is installed (not showing installation page)
    if docker exec wordpress wp core is-installed --allow-root > /dev/null 2>&1; then
        print_success "WordPress is properly installed"
    else
        print_error "WordPress installation not complete"
        return 1
    fi
    
    # Check site URL configuration
    local site_url=$(docker exec wordpress wp option get siteurl --allow-root 2>/dev/null)
    if [ "$site_url" = "https://$DOMAIN" ]; then
        print_success "WordPress site URL configured correctly: $site_url"
    else
        print_error "WordPress site URL misconfigured: $site_url (expected https://$DOMAIN)"
        return 1
    fi
    
    # Check if no installation page is visible
    local page_content=$(curl -k -s "https://$DOMAIN" | head -20)
    if echo "$page_content" | grep -qi "wordpress.*install\|installation.*wordpress\|setup.*wordpress\|wp-admin/install"; then
        print_error "WordPress installation page is still visible"
        echo "Found installation-related content in the page"
        return 1
    else
        print_success "No WordPress installation page visible"
    fi
    
    # Verify WordPress admin is accessible (should redirect to login)
    local admin_response=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/wp-admin/")
    if [ "$admin_response" = "200" ] || [ "$admin_response" = "302" ]; then
        print_success "WordPress admin accessible (HTTP $admin_response)"
    else
        print_warning "WordPress admin response: $admin_response (may need login)"
    fi
}

# Test 6: Test SSL/TLS Certificate
test_ssl() {
    print_header "TEST 6: SSL/TLS CERTIFICATE"
    
    echo "Checking SSL/TLS certificate..."
    
    # Check if SSL certificate is present and valid
    if echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | grep -q "$DOMAIN"; then
        print_success "SSL certificate contains correct domain"
    else
        print_warning "SSL certificate domain check inconclusive (self-signed certificate)"
    fi
    
    # Check certificate expiry
    local cert_info=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    if [ $? -eq 0 ]; then
        print_success "SSL certificate is readable and valid"
        echo "$cert_info"
    else
        print_error "Cannot read SSL certificate"
        return 1
    fi
    
    # Verify SSL connection is working
    if curl -k -s -I "https://$DOMAIN" | grep -q "HTTP"; then
        print_success "SSL/TLS connection established successfully"
    else
        print_error "SSL/TLS connection failed"
        return 1
    fi
    
    # Check SSL protocol version
    local ssl_version=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | grep "Protocol" | head -1)
    if [ -n "$ssl_version" ]; then
        print_success "SSL Protocol: $ssl_version"
    else
        print_warning "Could not determine SSL protocol version"
    fi
}

# Test 7: Test MariaDB database
test_database() {
    print_header "TEST 7: MARIADB DATABASE"
    
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

# Test 8: Test WordPress functionality
test_wordpress() {
    print_header "TEST 8: WORDPRESS FUNCTIONALITY"
    
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

# Test 9: Test Nginx configuration and port 443
test_nginx() {
    print_header "TEST 9: NGINX CONFIGURATION & PORT 443"
    
    echo "Testing Nginx configuration..."
    
    # Test Nginx config syntax
    if docker exec nginx nginx -t > /dev/null 2>&1; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
        docker exec nginx nginx -t
        return 1
    fi
    
    # Test if Nginx is serving ONLY on port 443
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
    
    # Verify Nginx is NOT listening on port 80 (HTTP should be blocked)
    if docker exec nginx netstat -tlnp 2>/dev/null | grep -q ":80" || docker exec nginx ss -tlnp 2>/dev/null | grep -q ":80"; then
        print_warning "Nginx is listening on port 80 (HTTP) - should be blocked or redirected"
    else
        print_success "Nginx not listening on port 80 (HTTP properly blocked)"
    fi
    
    # Check that only port 443 is accessible from outside
    local port_443_accessible=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN:443" 2>/dev/null)
    if [ "$port_443_accessible" = "200" ]; then
        print_success "Port 443 accessible from outside"
    else
        print_error "Port 443 not accessible from outside (response: $port_443_accessible)"
        return 1
    fi
}

# Test 10: Test data persistence
test_persistence() {
    print_header "TEST 10: DATA PERSISTENCE"
    
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

# Test 11: Test website content
test_website_content() {
    print_header "TEST 11: WEBSITE CONTENT"
    
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

# Test 12: Evaluation Criteria Compliance
test_evaluation_criteria() {
    print_header "TEST 12: EVALUATION CRITERIA COMPLIANCE"
    
    echo "Verifying 42 evaluation criteria..."
    
    # 1. Nginx accessible by port 443 only
    print_info "✓ Checking: Nginx accessible by port 443 only"
    local port_443_test=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN:443" 2>/dev/null)
    if [ "$port_443_test" = "200" ]; then
        print_success "Nginx accessible via port 443"
    else
        print_error "Nginx not accessible via port 443"
        return 1
    fi
    
    # 2. SSL/TLS certificate is used
    print_info "✓ Checking: SSL/TLS certificate is used"
    if echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | grep -q "CONNECTED"; then
        print_success "SSL/TLS certificate is being used"
    else
        print_error "SSL/TLS certificate not working"
        return 1
    fi
    
    # 3. WordPress properly installed (no installation page)
    print_info "✓ Checking: WordPress properly installed (no installation page)"
    if docker exec wordpress wp core is-installed --allow-root > /dev/null 2>&1; then
        local page_check=$(curl -k -s "https://$DOMAIN" | head -10)
        if echo "$page_check" | grep -qi "installation\|install.*wordpress\|wp-admin/install"; then
            print_error "WordPress installation page still visible"
            return 1
        else
            print_success "WordPress properly installed (no installation page)"
        fi
    else
        print_error "WordPress not properly installed"
        return 1
    fi
    
    # 4. Site accessible via https://yilin.42.fr (not http)
    print_info "✓ Checking: Site accessible via https://$DOMAIN only"
    local https_test=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN" 2>/dev/null)
    local http_test=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$https_test" = "200" ] && [ "$http_test" != "200" ]; then
        print_success "Site accessible via HTTPS only (HTTPS: $https_test, HTTP: $http_test)"
    else
        print_error "Site accessibility issue (HTTPS: $https_test, HTTP: $http_test)"
        return 1
    fi
    
    print_success "🎯 ALL EVALUATION CRITERIA MET!"
}

# Test 13: Test WordPress User Functionality & PHP-FPM
test_wordpress_users() {
    print_header "TEST 13: WORDPRESS USER FUNCTIONALITY & PHP-FPM"
    
    echo "Testing WordPress user system and PHP-FPM..."
    
    # 1. Test PHP-FPM is running
    print_info "✓ Checking: PHP-FPM process is running"
    if docker exec wordpress pgrep php-fpm > /dev/null 2>&1; then
        local php_processes=$(docker exec wordpress pgrep php-fpm | wc -l)
        print_success "PHP-FPM is running ($php_processes processes)"
    else
        print_error "PHP-FPM is not running"
        return 1
    fi
    
    # 2. Test PHP-FPM port 9000
    print_info "✓ Checking: PHP-FPM listening on port 9000"
    if docker exec wordpress netstat -tlnp 2>/dev/null | grep -q ":9000" || docker exec wordpress ss -tlnp 2>/dev/null | grep -q ":9000"; then
        print_success "PHP-FPM listening on port 9000"
    else
        print_error "PHP-FPM not listening on port 9000"
        return 1
    fi
    
    # 3. Test WordPress users exist
    print_info "✓ Checking: WordPress users are configured"
    local user_count=$(docker exec wordpress wp user list --format=count --allow-root 2>/dev/null)
    if [ "$user_count" -gt 0 ]; then
        print_success "WordPress users found ($user_count users)"
        
        # List users
        echo "WordPress users:"
        docker exec wordpress wp user list --fields=ID,user_login,user_email,roles --allow-root 2>/dev/null || true
    else
        print_error "No WordPress users found"
        return 1
    fi
    
    # 4. Test WordPress admin user
    print_info "✓ Checking: WordPress admin user exists"
    if docker exec wordpress wp user list --role=administrator --format=count --allow-root 2>/dev/null | grep -q "[1-9]"; then
        local admin_user=$(docker exec wordpress wp user list --role=administrator --field=user_login --allow-root 2>/dev/null | head -1)
        print_success "WordPress admin user exists: $admin_user"
    else
        print_error "No WordPress admin user found"
        return 1
    fi
    
    # 5. Test WordPress regular user
    print_info "✓ Checking: WordPress regular user exists"
    local regular_users=$(docker exec wordpress wp user list --role=subscriber,author,editor,contributor --format=count --allow-root 2>/dev/null)
    if [ "$regular_users" -gt 0 ]; then
        local regular_user=$(docker exec wordpress wp user list --role=subscriber,author,editor,contributor --field=user_login --allow-root 2>/dev/null | head -1)
        print_success "WordPress regular user exists: $regular_user"
    else
        print_warning "No regular WordPress users found (only admin exists)"
    fi
    
    # 6. Test comment system is enabled
    print_info "✓ Checking: WordPress comment system is enabled"
    local comments_enabled=$(docker exec wordpress wp option get default_comment_status --allow-root 2>/dev/null)
    if [ "$comments_enabled" = "open" ]; then
        print_success "WordPress comments are enabled"
    else
        print_warning "WordPress comments may be disabled (status: $comments_enabled)"
    fi
    
    # 7. Test existing posts allow comments
    print_info "✓ Checking: Posts allow comments"
    local posts_with_comments=$(docker exec wordpress wp post list --field=ID --comment_status=open --allow-root 2>/dev/null | wc -l)
    if [ "$posts_with_comments" -gt 0 ]; then
        print_success "Found $posts_with_comments posts that allow comments"
    else
        print_warning "No posts found that allow comments"
    fi
    
    # 8. Test if we can create a test comment (using WP-CLI)
    print_info "✓ Testing: Comment creation functionality"
    local test_post_id=$(docker exec wordpress wp post list --field=ID --posts_per_page=1 --allow-root 2>/dev/null | head -1)
    if [ -n "$test_post_id" ]; then
        # Try to create a test comment
        if docker exec wordpress wp comment create --comment_post_ID="$test_post_id" --comment_content="Test comment for evaluation" --comment_author="Test User" --comment_author_email="test@example.com" --allow-root > /dev/null 2>&1; then
            print_success "Comment creation functionality works"
            
            # Clean up the test comment
            local test_comment_id=$(docker exec wordpress wp comment list --post_id="$test_post_id" --format=ids --allow-root 2>/dev/null | tail -1)
            docker exec wordpress wp comment delete "$test_comment_id" --force --allow-root > /dev/null 2>&1 || true
        else
            print_warning "Comment creation test failed (may be due to restrictions)"
        fi
    else
        print_warning "No posts found to test comment functionality"
    fi
    
    # 9. Test PHP-FPM and Nginx communication
    print_info "✓ Testing: PHP-FPM and Nginx communication"
    # Test a PHP page to ensure PHP-FPM is processing requests
    local php_response=$(curl -k -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/wp-admin/admin-ajax.php" 2>/dev/null)
    if [ "$php_response" = "400" ] || [ "$php_response" = "403" ] || [ "$php_response" = "200" ]; then
        print_success "PHP-FPM processing requests (response: $php_response)"
    else
        print_error "PHP-FPM not processing requests properly (response: $php_response)"
        return 1
    fi
    
    print_success "✅ WordPress user functionality and PHP-FPM tests completed"
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
    local total_tests=13
    
    # Run all tests
    test_compose_file || ((failed_tests++))
    test_containers || ((failed_tests++))
    test_network || ((failed_tests++))
    test_https || ((failed_tests++))
    test_wordpress_installation || ((failed_tests++))
    test_ssl || ((failed_tests++))
    test_database || ((failed_tests++))
    test_wordpress || ((failed_tests++))
    test_nginx || ((failed_tests++))
    test_persistence || ((failed_tests++))
    test_website_content || ((failed_tests++))
    test_wordpress_users || ((failed_tests++))
    
    # Run evaluation criteria test
    test_evaluation_criteria || ((failed_tests++))
    
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
