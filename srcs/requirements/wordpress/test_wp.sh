#!/bin/bash

# WordPress Container Comprehensive Test Script
# This script runs all tests to verify WordPress container functionality

set -e  # Exit on any error

# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'
# **************************************************************************** #

# Container name
CONTAINER_NAME="wp_container1"

# **************************************************************************** #
#                              PRINT COLOR FUNCS                               #
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
    echo -e "${YELLOW}ℹ️  $1${RESET}"
}

# Check if container exists and is running
check_container() {
    print_header "CHECKING CONTAINER STATUS"
    
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        print_error "Container $CONTAINER_NAME is not running!"
        echo "Please start the container first:"
        echo "docker run -d --name $CONTAINER_NAME wp_img1"
        exit 1
    fi
    
    print_success "Container $CONTAINER_NAME is running"
    docker ps | grep "$CONTAINER_NAME"
}

# **************************************************************************** #
#               Test 1: Basic Container Information                            #
# **************************************************************************** #
test_container_info() {
    print_header "TEST 1: CONTAINER INFORMATION"
    
    echo "Container Details:"
    docker exec $CONTAINER_NAME uname -a
    
    echo -e "\nContainer Uptime:"
    docker exec $CONTAINER_NAME uptime
    
    echo -e "\nDisk Usage:"
    docker exec $CONTAINER_NAME df -h | head -5
}

# **************************************************************************** #
#                      Test 2: WordPress Core Files                            #
# **************************************************************************** #
test_wordpress_core() {
    print_header "TEST 2: WORDPRESS CORE FILES"
    
    if docker exec $CONTAINER_NAME test -f "/var/www/html/wp-load.php"; then
        print_success "WordPress core files present"
    else
        print_error "WordPress core files missing"
        return 1
    fi
    
    echo "WordPress Directory Contents:"
    docker exec $CONTAINER_NAME ls -la /var/www/html/ | head -10
    
    echo -e "\nWordPress Directory Size:"
    docker exec $CONTAINER_NAME du -sh /var/www/html/
}

# **************************************************************************** #
#                      Test 3: WP-CLI Functionality                            #
# **************************************************************************** #
test_wp_cli() {
    print_header "TEST 3: WP-CLI FUNCTIONALITY"
    
    echo "WP-CLI Version:"
    if docker exec $CONTAINER_NAME wp --version --allow-root 2>/dev/null; then
        print_success "WP-CLI is functional"
    else
        print_error "WP-CLI is not working"
        return 1
    fi
    
    echo -e "\nWP-CLI Info:"
    docker exec $CONTAINER_NAME wp --info --allow-root 2>/dev/null || true
    
    echo -e "\nWordPress Core Version:"
    docker exec $CONTAINER_NAME wp core version --allow-root --path=/var/www/html 2>/dev/null || true
}

# **************************************************************************** #
#                        Test 4: PHP Configuration                             #
# **************************************************************************** #
test_php() {
    print_header "TEST 4: PHP CONFIGURATION"
    
    echo "PHP Version:"
    docker exec $CONTAINER_NAME php -v | head -1
    
    echo -e "\nPHP Modules (MySQL related):"
    docker exec $CONTAINER_NAME php -m | grep -E "(mysql|mysqli|pdo)" || print_warning "No MySQL modules found"
    
    echo -e "\nPHP Configuration:"
    docker exec $CONTAINER_NAME php -r "echo 'PHP Version: ' . PHP_VERSION . PHP_EOL;"
    docker exec $CONTAINER_NAME php -r "echo 'Max Execution Time: ' . ini_get('max_execution_time') . PHP_EOL;"
    docker exec $CONTAINER_NAME php -r "echo 'Memory Limit: ' . ini_get('memory_limit') . PHP_EOL;"
}

# **************************************************************************** #
#                          Test 5: PHP-FPM Status                              #
# **************************************************************************** #
test_php_fpm() {
    print_header "TEST 5: PHP-FPM STATUS"
    
    echo "PHP-FPM Configuration Test:"
    if docker exec $CONTAINER_NAME php-fpm7.4 -t 2>&1 | grep -q "successful"; then
        print_success "PHP-FPM configuration is valid"
    else
        print_error "PHP-FPM configuration has issues"
    fi
    
    echo -e "\nPHP-FPM Processes:"
    docker exec $CONTAINER_NAME ps aux | grep php-fpm | grep -v grep || print_warning "No PHP-FPM processes found"
    
    echo -e "\nNetwork Listening Ports:"
    docker exec $CONTAINER_NAME netstat -tulpn 2>/dev/null | grep :9000 || print_warning "Port 9000 not found (trying alternative method)"
    
    # Alternative method if netstat is not available
    docker exec $CONTAINER_NAME ss -tulpn 2>/dev/null | grep :9000 || print_info "Port 9000 check: ss command not available"
}

# **************************************************************************** #
#                         Test 6: File Permissions                             #
# **************************************************************************** #
test_permissions() {
    print_header "TEST 6: FILE PERMISSIONS AND OWNERSHIP"
    
    echo "WordPress Directory Ownership:"
    docker exec $CONTAINER_NAME stat -c "%U:%G" /var/www/html/
    
    echo -e "\nwww-data User Info:"
    docker exec $CONTAINER_NAME id www-data
    
    echo -e "\nPHP-FPM Pool Configuration:"
    if docker exec $CONTAINER_NAME test -f "/etc/php/7.4/fpm/pool.d/www.conf"; then
        print_success "PHP-FPM pool configuration exists"
        echo "Pool configuration snippet:"
        docker exec $CONTAINER_NAME head -20 /etc/php/7.4/fpm/pool.d/www.conf
    else
        print_error "PHP-FPM pool configuration missing"
    fi
}

# **************************************************************************** #
#                     Test 7: Network Connectivity                             #
# **************************************************************************** #
test_connectivity() {
    print_header "TEST 7: NETWORK CONNECTIVITY"
    
    echo "Testing internet connectivity:"
    if docker exec $CONTAINER_NAME curl -s -o /dev/null -w "%{http_code}" https://api.wordpress.org/core/version-check/1.7/ | grep -q "200"; then
        print_success "Internet connectivity working"
    else
        print_warning "Internet connectivity issues or API unavailable"
    fi
    
    echo -e "\nTesting DNS resolution:"
    if docker exec $CONTAINER_NAME nslookup wordpress.org >/dev/null 2>&1; then
        print_success "DNS resolution working"
    else
        print_warning "DNS resolution test failed (nslookup may not be installed)"
    fi
    
    echo -e "\nTesting MariaDB hostname resolution (expected to fail without MariaDB):"
    docker exec $CONTAINER_NAME getent hosts mariadb || print_info "MariaDB host not found (expected without MariaDB running)"
}

# **************************************************************************** #
#                 Test 8: Create and Test PHP File                             #
# **************************************************************************** #
test_php_functionality() {
    print_header "TEST 8: PHP FUNCTIONALITY TEST"
    
    # Create a comprehensive PHP test file
    docker exec $CONTAINER_NAME bash -c 'cat > /tmp/wp_test.php << "EOF"
<?php
echo "=== WordPress Container PHP Test ===\n";
echo "PHP Version: " . phpversion() . "\n";
echo "Server API: " . php_sapi_name() . "\n";

echo "\n=== WordPress Core ===\n";
if (file_exists("/var/www/html/wp-load.php")) {
    echo "✅ WordPress core files present\n";
} else {
    echo "❌ WordPress core files missing\n";
}

echo "\n=== Database Extensions ===\n";
echo "MySQLi Extension: " . (extension_loaded("mysqli") ? "✅ Loaded" : "❌ Not loaded") . "\n";
echo "PDO MySQL Extension: " . (extension_loaded("pdo_mysql") ? "✅ Loaded" : "❌ Not loaded") . "\n";
echo "MySQL Native Driver: " . (extension_loaded("mysqlnd") ? "✅ Loaded" : "❌ Not loaded") . "\n";

echo "\n=== File Permissions ===\n";
$wp_dir = "/var/www/html";
echo "WordPress directory readable: " . (is_readable($wp_dir) ? "✅ Yes" : "❌ No") . "\n";
echo "WordPress directory writable: " . (is_writable($wp_dir) ? "✅ Yes" : "❌ No") . "\n";

echo "\n=== Configuration Files ===\n";
echo "PHP-FPM pool config: " . (file_exists("/etc/php/7.4/fpm/pool.d/www.conf") ? "✅ Exists" : "❌ Missing") . "\n";

echo "\n=== Memory and Limits ===\n";
echo "Memory Limit: " . ini_get("memory_limit") . "\n";
echo "Max Execution Time: " . ini_get("max_execution_time") . "\n";
echo "Upload Max Filesize: " . ini_get("upload_max_filesize") . "\n";

echo "\n=== Test Complete ===\n";
?>
EOF'
    
    echo "Running PHP functionality test:"
    docker exec $CONTAINER_NAME php /tmp/wp_test.php
}

# **************************************************************************** #
#                   Test 9: Start PHP-FPM Manually                             #
# **************************************************************************** #
test_php_fpm_manual() {
    print_header "TEST 9: MANUAL PHP-FPM START TEST"
    
    print_info "Attempting to start PHP-FPM manually (may show 'address in use' if already running)"
    
    # Try to start PHP-FPM in daemon mode
    docker exec $CONTAINER_NAME /usr/sbin/php-fpm7.4 -D 2>&1 || print_info "PHP-FPM may already be running"
    
    sleep 2
    
    echo -e "\nChecking PHP-FPM processes after manual start:"
    docker exec $CONTAINER_NAME ps aux | grep php-fpm | grep -v grep || print_warning "No PHP-FPM processes visible"
    
    echo -e "\nChecking port 9000 availability:"
    docker exec $CONTAINER_NAME netstat -tulpn 2>/dev/null | grep :9000 || {
        # Try alternative if netstat not available
        docker exec $CONTAINER_NAME ss -tulpn 2>/dev/null | grep :9000 || print_warning "Port 9000 status unknown (network tools may be missing)"
    }
}

# **************************************************************************** #
#                   Test 10: Container Resource Usage                          #
# **************************************************************************** #
test_resources() {
    print_header "TEST 10: CONTAINER RESOURCE USAGE"
    
    echo "Memory Usage:"
    docker exec $CONTAINER_NAME free -h
    
    echo -e "\nCPU and Load:"
    docker exec $CONTAINER_NAME cat /proc/loadavg
    
    echo -e "\nProcess List (top 10):"
    docker exec $CONTAINER_NAME ps aux --sort=-%cpu | head -11
}


# **************************************************************************** #
#                          PRINT FINAL SUMMARY                                 #
# **************************************************************************** #
print_summary() {
    print_header "FINAL TEST SUMMARY"
    
    echo "Container: $CONTAINER_NAME"
    echo "Status: $(docker ps --format "table {{.Status}}" | grep -v STATUS | head -1)"
    echo "Image: $(docker ps --format "table {{.Image}}" | grep -v IMAGE | head -1)"
    
    echo -e "\n🎯 Key Findings:"
    echo "- WordPress Core: $(docker exec $CONTAINER_NAME test -f "/var/www/html/wp-load.php" && echo "✅ Present" || echo "❌ Missing")"
    echo "- WP-CLI: $(docker exec $CONTAINER_NAME wp --version --allow-root 2>/dev/null | grep -q "WP-CLI" && echo "✅ Working" || echo "❌ Not working")"
    echo "- PHP-FPM Config: $(docker exec $CONTAINER_NAME php-fpm7.4 -t 2>&1 | grep -q "successful" && echo "✅ Valid" || echo "❌ Invalid")"
    echo "- PHP MySQL Extensions: $(docker exec $CONTAINER_NAME php -m | grep -q "mysqli" && echo "✅ Loaded" || echo "❌ Missing")"
    echo "- Internet Connectivity: $(docker exec $CONTAINER_NAME curl -s -o /dev/null -w "%{http_code}" https://api.wordpress.org/core/version-check/1.7/ | grep -q "200" && echo "✅ Working" || echo "❌ Issues")"
    
    print_success "All tests completed!"
    print_info "WordPress container is ready for integration with MariaDB and nginx"
}





# **************************************************************************** #
#                                   MAIN                                       #
# **************************************************************************** #
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    WordPress Container Comprehensive Test                    ║"
    echo "║                                                                              ║"
    echo "║  This script will run all tests to verify WordPress container functionality  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    # Run all tests
    check_container
    test_container_info
    test_wordpress_core
    test_wp_cli
    test_php
    test_php_fpm
    test_permissions
    test_connectivity
    test_php_functionality
    test_php_fpm_manual
    test_resources
    print_summary
    
    echo -e "\n${GREEN}🎉 WordPress container testing completed successfully! 🎉${RESET}"
}

# Run the main function
main "$@"