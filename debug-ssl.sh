#!/bin/bash

echo "🔍 SSL Debug Information"
echo "======================="

# Load configuration if exists
if [ -f "docker/config.env" ]; then
    source docker/config.env
    echo "✅ Configuration loaded from docker/config.env"
    echo "   PROJECT_NAME: $PROJECT_NAME"
    echo "   APP_PORT: $APP_PORT"
    echo "   APP_HTTPS_PORT: $APP_HTTPS_PORT"
else
    echo "❌ Configuration file not found: docker/config.env"
    echo "   Run: ./docker-dev.sh configure"
    exit 1
fi

echo ""
echo "🐳 Docker Container Status"
echo "=========================="
docker compose ps

echo ""
echo "🔗 Port Mapping Check"
echo "====================="
docker compose port app 80 2>/dev/null || echo "❌ HTTP port not mapped"
docker compose port app 443 2>/dev/null || echo "❌ HTTPS port not mapped"

echo ""
echo "📋 Container SSL Diagnostic"
echo "==========================="
if docker compose exec app bash -c "test -f /etc/ssl/certs/apache-selfsigned.crt"; then
    echo "✅ SSL certificate exists"
else
    echo "❌ SSL certificate missing"
fi

if docker compose exec app bash -c "test -f /etc/ssl/private/apache-selfsigned.key"; then
    echo "✅ SSL private key exists"
else
    echo "❌ SSL private key missing"
fi

echo ""
echo "🔧 Apache Configuration Check"
echo "============================="
echo "Apache modules status:"
docker compose exec app apache2ctl -M | grep -E "(ssl|rewrite|headers)" || echo "❌ Required modules not loaded"

echo ""
echo "Apache site status:"
docker compose exec app apache2ctl -S 2>/dev/null | grep -E "(443|80)" || echo "❌ Virtual hosts not configured properly"

echo ""
echo "🔍 SSL Certificate Details"
echo "=========================="
docker compose exec app openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -text -noout | grep -E "(Subject:|Not Before:|Not After:|DNS:)" 2>/dev/null || echo "❌ Cannot read certificate"

echo ""
echo "📝 Apache Error Logs (last 10 lines)"
echo "===================================="
docker compose exec app tail -10 /var/log/apache2/error.log 2>/dev/null || echo "❌ Cannot read Apache error logs"

echo ""
echo "🌐 Connection Test"
echo "=================="
echo "Testing HTTP connection:"
curl -I -s "http://localhost:$APP_PORT" | head -1 || echo "❌ HTTP connection failed"

echo ""
echo "Testing HTTPS connection (ignore certificate warnings):"
curl -I -s -k "https://localhost:$APP_HTTPS_PORT" | head -1 || echo "❌ HTTPS connection failed"

echo ""
echo "🔧 Quick Fix Commands"
echo "===================="
echo "If SSL is not working, try these commands:"
echo ""
echo "1. Rebuild containers:"
echo "   ./docker-dev.sh stop"
echo "   docker compose build --no-cache"
echo "   ./docker-dev.sh start"
echo ""
echo "2. Regenerate SSL certificates:"
echo "   docker compose exec app bash -c 'rm -f /etc/ssl/certs/apache-selfsigned.* /etc/ssl/private/apache-selfsigned.*'"
echo "   ./docker-dev.sh restart"
echo ""
echo "3. Check container logs:"
echo "   ./docker-dev.sh app-logs" 