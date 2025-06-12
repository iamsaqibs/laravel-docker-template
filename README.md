# Laravel Docker Development Template

A reusable Docker development environment template for Laravel applications, optimized for **OrbStack** and development workflows.

## 🚀 Quick Setup for Any Laravel Project

### Prerequisites

- [OrbStack](https://orbstack.dev/) installed and running
- A Laravel project

### Setup Instructions

1. **Copy this template to your Laravel project root:**
   ```bash
   # Copy the entire laravel-docker-template directory to your Laravel project
   cp -r /path/to/laravel-docker-template/* /path/to/your/laravel/project/
   ```

2. **Configure your project:**
   ```bash
   # Navigate to your Laravel project
   cd /path/to/your/laravel/project
   
   # Edit the docker/.env.template file to match your project needs
   # The setup script will guide you through this
   ```

3. **Run the setup:**
   ```bash
   ./docker-dev.sh setup
   ```

   This will:
   - Prompt you for project configuration
   - Generate docker-compose.yml and environment files
   - Build all containers
   - Start all services
   - Run database migrations

4. **Access your application:**
   - **Laravel App (HTTPS)**: https://localhost:8443 (or your configured HTTPS port)
   - **Laravel App (HTTP)**: http://localhost:8080 (redirects to HTTPS)
   - **PHPMyAdmin**: http://localhost:8081 (or your configured port)
   - **Mailhog**: http://localhost:8025 (or your configured port)

## 🔧 Configuration

The template uses a configuration file `docker/.env.template` where you can customize:

- **Project name** (affects container names and network)
- **Database name, username, and password**
- **Port mappings** (HTTP and HTTPS ports to avoid conflicts with other projects)
- **Application URL** (automatically configured for HTTPS)

## 🛠️ Development Workflow

### Helper Script Commands

```bash
# Start/Stop Services
./docker-dev.sh start      # Start all services
./docker-dev.sh stop       # Stop all services
./docker-dev.sh restart    # Restart all services

# Development Tasks
./docker-dev.sh shell      # Open shell in app container
./docker-dev.sh logs       # View all container logs
./docker-dev.sh app-logs   # View app container logs only

# Laravel Commands
./docker-dev.sh artisan migrate
./docker-dev.sh artisan make:model Product
./docker-dev.sh artisan queue:work

# Package Management
./docker-dev.sh composer install
./docker-dev.sh composer require package/name
./docker-dev.sh npm install
./docker-dev.sh npm run dev

# Database Access
./docker-dev.sh mysql      # Connect to MySQL CLI
./docker-dev.sh redis      # Connect to Redis CLI

# Testing
./docker-dev.sh test       # Run PHPUnit tests

# Maintenance
./docker-dev.sh status     # Show container status
./docker-dev.sh fresh      # Fresh install (destroys data!)
./docker-dev.sh cleanup    # Remove all containers and volumes
```

## 🔍 Features

This Docker environment includes:

- **Laravel App** (PHP 8.2 + Apache with SSL/HTTPS) - Main application container
- **MySQL 8.0** - Database with persistent storage
- **Redis 7** - Caching and session storage
- **Mailhog** - Email testing tool
- **PHPMyAdmin** - Database management interface
- **Xdebug** - Pre-configured for VS Code debugging
- **Self-signed SSL certificates** - Automatic HTTPS setup for development

## 📂 Template Structure

```
laravel-docker-template/
├── docker/
│   ├── dev/
│   │   ├── Dockerfile           # PHP/Apache container
│   │   ├── 000-default.conf     # Apache configuration
│   │   ├── php.ini             # PHP configuration
│   │   ├── supervisord.conf     # Process manager
│   │   ├── entrypoint.sh        # Container startup script
│   │   ├── env.example          # Laravel environment template
│   │   └── mysql/
│   │       └── init.sql         # Database initialization
│   └── .env.template           # Docker configuration template
├── .vscode/
│   └── launch.json             # VS Code debug configuration
├── .dockerignore               # Docker ignore file
├── docker-compose.yml.template # Docker Compose template
├── docker-dev.sh              # Development helper script
└── README.md                  # This file
```

## 🔄 Using with Multiple Projects

You can run multiple Laravel projects simultaneously by:

1. Using different port mappings for each project
2. Using different project names
3. Each project will have its own isolated containers and networks

Example configurations for multiple projects:

**Project A** (HTTP: 8080, HTTPS: 8443, PHPMyAdmin: 8081, Mailhog: 8025):
```env
PROJECT_NAME=project_a
APP_PORT=8080
APP_HTTPS_PORT=8443
PHPMYADMIN_PORT=8081
MAILHOG_WEB_PORT=8025
```

**Project B** (HTTP: 8090, HTTPS: 8453, PHPMyAdmin: 8091, Mailhog: 8035):
```env
PROJECT_NAME=project_b
APP_PORT=8090
APP_HTTPS_PORT=8453
PHPMYADMIN_PORT=8091
MAILHOG_WEB_PORT=8035
```

## 🔒 HTTPS/SSL Information

### SSL Certificates

The template automatically generates self-signed SSL certificates during the Docker build process. These certificates are valid for `localhost` and are suitable for development purposes.

**Browser Warning**: Since these are self-signed certificates, your browser will show a security warning. You can safely proceed by:
1. Clicking "Advanced" in your browser
2. Selecting "Proceed to localhost (unsafe)" or similar option

### Certificate Details

- **Certificate Location**: `/etc/ssl/certs/apache-selfsigned.crt`
- **Private Key Location**: `/etc/ssl/private/apache-selfsigned.key`
- **Valid For**: `localhost`
- **Validity**: 365 days from build date

### Custom SSL Certificates

To use your own SSL certificates:
1. Replace the certificate files in the container
2. Update the Apache configuration if needed
3. Rebuild the container

## 🚨 Troubleshooting

### Port Conflicts

If you get port conflicts:
1. Edit `docker/.env.template` to use different ports
2. Run `./docker-dev.sh fresh` to rebuild with new configuration

### Permission Issues

```bash
./docker-dev.sh shell
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
```

### Database Issues

```bash
# Check if MySQL is ready
./docker-dev.sh mysql

# Reset database
./docker-dev.sh fresh
```

## 📚 Next Steps

After setup:
1. Update your `.env` file with any additional configuration
2. Install your project dependencies: `./docker-dev.sh composer install`
3. Run migrations: `./docker-dev.sh artisan migrate`
4. Start developing! 