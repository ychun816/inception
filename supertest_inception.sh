#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 INCEPTION SUPER TEST SCRIPT 🚀${NC}"
echo "=================================="
echo ""

# Test SSL/TLS
echo -e "${RED}🔒 SSL/TLS TESTS 🔒${NC}"
echo "==================="

echo "🧪 Testing SSL certificate..."
openssl s_client -connect yilin.42.fr:443 -servername yilin.42.fr < /dev/null 2>/dev/null | openssl x509 -noout -subject 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ SSL certificate is valid${NC}"
else
    echo -e "${RED}❌ SSL certificate test failed${NC}"
fi

echo "🧪 Testing TLS version..."
TLS_VERSION=$(openssl s_client -connect yilin.42.fr:443 -servername yilin.42.fr < /dev/null 2>/dev/null | grep "Protocol" | head -1)
if [[ "$TLS_VERSION" == *"TLSv1.2"* ]] || [[ "$TLS_VERSION" == *"TLSv1.3"* ]]; then
    echo -e "${GREEN}✅ TLS version is secure: $TLS_VERSION${NC}"
else
    echo -e "${RED}❌ TLS version test failed: $TLS_VERSION${NC}"
fi

echo ""

# Test Docker containers
echo -e "${BLUE}🐳 CONTAINER TESTS 🐳${NC}"
echo "====================="

CONTAINERS=("nginx" "wordpress" "mariadb" "redis" "adminer")
for container in "${CONTAINERS[@]}"; do
    echo "🧪 Testing $container container..."
    docker ps | grep "$container" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $container container is running${NC}"
    else
        echo -e "${RED}❌ $container container not found${NC}"
    fi
done

echo ""

# Test Database
echo -e "${PURPLE}🗄️ DATABASE TESTS 🗄️${NC}"
echo "===================="

echo "🧪 Testing MariaDB connection..."
docker exec inception_mariadb_1 mysql -u root -phappybirthday -e "SELECT 1;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ MariaDB connection successful${NC}"
else
    echo -e "${RED}❌ MariaDB connection failed${NC}"
fi

echo "🧪 Testing WordPress database..."
docker exec inception_mariadb_1 mysql -u yilin -phappybirthday -e "USE wordpress; SHOW TABLES;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ WordPress database accessible${NC}"
else
    echo -e "${RED}❌ WordPress database test failed${NC}"
fi

echo "🧪 Testing database users..."
USER_COUNT=$(docker exec inception_mariadb_1 mysql -u root -phappybirthday -e "SELECT COUNT(*) FROM mysql.user WHERE User='yilin';" -s -N 2>/dev/null)
if [ "$USER_COUNT" -eq 1 ]; then
    echo -e "${GREEN}✅ Database user 'yilin' exists${NC}"
else
    echo -e "${RED}❌ Database user test failed${NC}"
fi

echo ""

# Test WordPress
echo -e "${YELLOW}📝 WORDPRESS TESTS 📝${NC}"
echo "===================="

echo "🧪 Testing WordPress homepage..."
curl -k -s https://yilin.42.fr/ | grep -i "wordpress\|inception" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ WordPress homepage accessible${NC}"
else
    echo -e "${RED}❌ WordPress homepage test failed${NC}"
fi

echo "🧪 Testing WordPress admin..."
ADMIN_RESPONSE=$(curl -k -s -w "%{http_code}" -o /dev/null https://yilin.42.fr/wp-admin/ 2>/dev/null)
if [ "$ADMIN_RESPONSE" = "302" ]; then
    echo -e "${GREEN}✅ WordPress admin redirect working (HTTP $ADMIN_RESPONSE)${NC}"
else
    echo -e "${RED}❌ WordPress admin test failed (HTTP $ADMIN_RESPONSE)${NC}"
fi

echo "🧪 Testing WordPress login page..."
curl -k -s https://yilin.42.fr/wp-login.php | grep -i "log in" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ WordPress login page accessible${NC}"
else
    echo -e "${RED}❌ WordPress login page test failed${NC}"
fi

echo "🧪 Testing WordPress users..."
WP_USERS=$(docker exec inception_wordpress_1 wp user list --allow-root 2>/dev/null | wc -l)
if [ "$WP_USERS" -gt 1 ]; then
    echo -e "${GREEN}✅ WordPress users configured ($((WP_USERS-1)) users)${NC}"
else
    echo -e "${RED}❌ WordPress users test failed${NC}"
fi

echo ""

# Test nginx
echo -e "${CYAN}🌐 NGINX TESTS 🌐${NC}"
echo "================="

echo "🧪 Testing nginx configuration..."
docker exec inception_nginx_1 nginx -t >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ nginx configuration is valid${NC}"
else
    echo -e "${RED}❌ nginx configuration test failed${NC}"
fi

echo "🧪 Testing HTTPS redirect..."
HTTP_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null http://yilin.42.fr/ 2>/dev/null)
if [ "$HTTP_RESPONSE" = "301" ] || [ "$HTTP_RESPONSE" = "302" ]; then
    echo -e "${GREEN}✅ HTTP to HTTPS redirect working (HTTP $HTTP_RESPONSE)${NC}"
else
    echo -e "${RED}❌ HTTPS redirect test failed (HTTP $HTTP_RESPONSE)${NC}"
fi

echo "🧪 Testing custom login URL..."
curl -k -s https://yilin.42.fr/user-login/ | grep -i "login" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Custom login URL working${NC}"
else
    echo -e "${RED}❌ Custom login URL test failed${NC}"
fi

echo ""

# Test Redis
echo -e "${RED}🔴 REDIS TESTS 🔴${NC}"
echo "===================="

echo "🧪 Testing Redis connection..."
docker exec inception_redis_1 redis-cli ping 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Redis is running and responsive${NC}"
else
    echo -e "${RED}❌ Redis connection failed${NC}"
fi

echo "🧪 Testing Redis data storage..."
docker exec inception_redis_1 redis-cli set test_key "inception_test" >/dev/null 2>&1
REDIS_GET=$(docker exec inception_redis_1 redis-cli get test_key 2>/dev/null)
if [ "$REDIS_GET" = "inception_test" ]; then
    echo -e "${GREEN}✅ Redis data storage/retrieval working${NC}"
    docker exec inception_redis_1 redis-cli del test_key >/dev/null 2>&1
else
    echo -e "${RED}❌ Redis data storage failed${NC}"
fi

echo "🧪 Testing Redis memory usage..."
REDIS_MEMORY=$(docker exec inception_redis_1 redis-cli info memory 2>/dev/null | grep used_memory_human)
if [ ! -z "$REDIS_MEMORY" ]; then
    echo -e "${GREEN}✅ Redis memory usage: $REDIS_MEMORY${NC}"
else
    echo -e "${RED}❌ Redis memory info failed${NC}"
fi

echo "🧪 Testing Redis keyspace..."
REDIS_KEYSPACE=$(docker exec inception_redis_1 redis-cli dbsize 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Redis keyspace accessible (keys: $REDIS_KEYSPACE)${NC}"
else
    echo -e "${RED}❌ Redis keyspace test failed${NC}"
fi

echo ""

# Test Adminer
echo -e "${PURPLE}🗄️ ADMINER TESTS 🗄️${NC}"
echo "===================="

echo "🧪 Testing Adminer container..."
docker ps | grep adminer >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Adminer container is running${NC}"
else
    echo -e "${RED}❌ Adminer container not found${NC}"
fi

echo "🧪 Testing Adminer web interface..."
ADMINER_RESPONSE=$(curl -k -s -w "%{http_code}" -o /dev/null https://yilin.42.fr/adminer/ 2>/dev/null)
if [ "$ADMINER_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Adminer web interface accessible (HTTP $ADMINER_RESPONSE)${NC}"
else
    echo -e "${RED}❌ Adminer web interface failed (HTTP $ADMINER_RESPONSE)${NC}"
fi

echo "🧪 Testing Adminer content..."
ADMINER_CONTENT=$(curl -k -s https://yilin.42.fr/adminer/ 2>/dev/null | grep -i "adminer")
if [ ! -z "$ADMINER_CONTENT" ]; then
    echo -e "${GREEN}✅ Adminer content loaded correctly${NC}"
else
    echo -e "${RED}❌ Adminer content test failed${NC}"
fi

echo "🧪 Testing Adminer database connectivity..."
ADMINER_DB_TEST=$(curl -k -s https://yilin.42.fr/adminer/ 2>/dev/null | grep -i "server\|database\|mysql")
if [ ! -z "$ADMINER_DB_TEST" ]; then
    echo -e "${GREEN}✅ Adminer database interface detected${NC}"
else
    echo -e "${RED}❌ Adminer database interface test failed${NC}"
fi

echo "🧪 Testing Adminer Apache service..."
docker exec inception_adminer_1 service apache2 status >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Adminer Apache service is running${NC}"
else
    echo -e "${RED}❌ Adminer Apache service failed${NC}"
fi

echo ""

# Volume Tests
echo -e "${YELLOW}💾 VOLUME TESTS 💾${NC}"
echo "=================="

echo "🧪 Testing data volumes..."
if [ -d "/home/yilin42/data/wordpress" ] && [ -d "/home/yilin42/data/mariadb" ]; then
    echo -e "${GREEN}✅ Data volumes exist${NC}"
else
    echo -e "${RED}❌ Data volumes test failed${NC}"
fi

echo "🧪 Testing WordPress files..."
docker exec inception_wordpress_1 ls -la /var/www/html/wp-config.php >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ WordPress files accessible${NC}"
else
    echo -e "${RED}❌ WordPress files test failed${NC}"
fi

echo ""

# Network Tests
echo -e "${CYAN}🌐 NETWORK TESTS 🌐${NC}"
echo "=================="

echo "🧪 Testing Docker network..."
docker network ls | grep inception >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker network 'inception' exists${NC}"
else
    echo -e "${RED}❌ Docker network test failed${NC}"
fi

echo "🧪 Testing container connectivity..."
docker exec inception_wordpress_1 ping -c 1 mariadb >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Container network connectivity working${NC}"
else
    echo -e "${RED}❌ Container network test failed${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}🎉 COMPLETE TEST SUMMARY 🎉${NC}"
echo "============================="

# SSL Summary
SSL_STATUS="❌ Failed"
openssl s_client -connect yilin.42.fr:443 -servername yilin.42.fr < /dev/null 2>/dev/null | openssl x509 -noout -subject >/dev/null 2>&1 && SSL_STATUS="✅ Working"
echo -e "SSL/TLS: $SSL_STATUS"

# Container Summary
CONTAINER_STATUS="❌ Failed"
docker ps | grep -E "(nginx|wordpress|mariadb|redis|adminer)" | wc -l | grep -q "5" && CONTAINER_STATUS="✅ Working"
echo -e "Containers: $CONTAINER_STATUS"

# Database Summary
DB_STATUS="❌ Failed"
docker exec inception_mariadb_1 mysql -u root -phappybirthday -e "SELECT 1;" >/dev/null 2>&1 && DB_STATUS="✅ Working"
echo -e "Database: $DB_STATUS"

# WordPress Summary
WP_STATUS="❌ Failed"
curl -k -s https://yilin.42.fr/ | grep -i "wordpress\|inception" >/dev/null 2>&1 && WP_STATUS="✅ Working"
echo -e "WordPress: $WP_STATUS"

# nginx Summary
NGINX_STATUS="❌ Failed"
docker exec inception_nginx_1 nginx -t >/dev/null 2>&1 && NGINX_STATUS="✅ Working"
echo -e "nginx: $NGINX_STATUS"

# Redis Summary
REDIS_STATUS="❌ Failed"
docker exec inception_redis_1 redis-cli ping >/dev/null 2>&1 && REDIS_STATUS="✅ Working"
echo -e "Redis: $REDIS_STATUS"

# Adminer Summary
ADMINER_STATUS="❌ Failed"
curl -k -s https://yilin.42.fr/adminer/ | grep -i "adminer" >/dev/null 2>&1 && ADMINER_STATUS="✅ Working"
echo -e "Adminer: $ADMINER_STATUS"

echo ""
echo -e "${CYAN}🚀 COMPLETE INCEPTION ARCHITECTURE TEST FINISHED! 🚀${NC}"
echo "=================================================="
echo ""
echo -e "${GREEN}Access your services:${NC}"
echo "• WordPress: https://yilin.42.fr/"
echo "• WordPress Admin: https://yilin.42.fr/wp-admin/"
echo "• Custom Login: https://yilin.42.fr/user-login/"
echo "• Adminer: https://yilin.42.fr/adminer/"
echo ""
echo -e "${BLUE}Login Credentials:${NC}"
echo "• WordPress Admin: yilin / happybirthday"
echo "• WordPress User: user / user123"
echo "• Adminer: Server=mariadb, User=yilin, Password=happybirthday"
echo ""