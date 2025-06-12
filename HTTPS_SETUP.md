# HTTPS Setup Guide

This Laravel Docker template now includes **automatic HTTPS support** with self-signed SSL certificates for development.

## 🔒 What's Changed

### SSL/HTTPS Features
- **Automatic SSL certificate generation** during Docker build
- **HTTP to HTTPS redirect** (all HTTP traffic redirects to HTTPS)
- **Enhanced security headers** for HTTPS
- **Dual port support** (HTTP and HTTPS ports)

### Port Configuration
- **HTTP Port**: 8080 (default) - redirects to HTTPS
- **HTTPS Port**: 8443 (default) - main application access
- Both ports are configurable during setup

## 🚀 Quick Start

1. **Run Setup** (same as before):
   ```bash
   ./docker-dev.sh setup
   ```

2. **Access Your App**:
   - **Primary**: https://localhost:8443
   - **Redirect**: http://localhost:8080 → https://localhost:8443

## ⚠️ Browser SSL Warning

Since we use self-signed certificates, your browser will show a security warning.

### Chrome/Safari:
1. You'll see "Your connection is not private"
2. Click **"Advanced"**
3. Click **"Proceed to localhost (unsafe)"**

### Firefox:
1. You'll see "Warning: Potential Security Risk Ahead"
2. Click **"Advanced"**
3. Click **"Accept the Risk and Continue"**

### First-Time Setup:
This warning appears only once per browser session. Click through it to access your Laravel application.

## 🔧 Configuration

### Custom Ports
During setup, you can customize both HTTP and HTTPS ports:
```
App HTTP port [8080]: 8080
App HTTPS port [8443]: 8443
```

### Multiple Projects
For multiple projects, use different port combinations:
```bash
# Project A
APP_PORT=8080
APP_HTTPS_PORT=8443

# Project B  
APP_PORT=8090
APP_HTTPS_PORT=8453

# Project C
APP_PORT=8100
APP_HTTPS_PORT=8463
```

## 🛠️ Technical Details

### SSL Certificate
- **Type**: Self-signed X.509 certificate
- **Key Size**: 2048-bit RSA
- **Validity**: 365 days
- **Subject**: `/C=US/ST=Development/L=Local/O=Laravel Docker/OU=Development/CN=localhost`

### Apache Configuration
- **SSL Module**: Enabled automatically
- **Security Headers**: HSTS, CSP, X-Frame-Options, etc.
- **HTTP Redirect**: All HTTP requests redirect to HTTPS

### Files Modified
- `docker/dev/000-default.conf` - Apache SSL virtual host
- `docker/dev/Dockerfile` - SSL module and certificate generation
- `docker-compose.yml.template` - HTTPS port mapping
- `docker-dev.sh` - HTTPS port configuration

## 🔄 Migration from HTTP

If you have an existing project using the old HTTP-only template:

1. **Backup your current setup**
2. **Copy the new template files**
3. **Run the configuration**:
   ```bash
   ./docker-dev.sh configure
   ./docker-dev.sh generate
   ./docker-dev.sh restart
   ```

## 🐛 Troubleshooting

### "Site Can't Be Reached"
- Check if HTTPS port (8443) is configured correctly
- Verify container is running: `./docker-dev.sh status`

### "SSL Connection Error"
- Restart containers: `./docker-dev.sh restart`
- Check Apache logs: `./docker-dev.sh app-logs`

### Port Already in Use
- Choose different ports during configuration
- Check what's using the port: `lsof -i :8443`

## 📚 Next Steps

Your Laravel application now runs on HTTPS by default, providing:
- **Enhanced security** for development
- **Production-like environment** for testing
- **Modern browser compatibility** with security headers

Continue development as normal - all Laravel features work exactly the same, just with HTTPS! 