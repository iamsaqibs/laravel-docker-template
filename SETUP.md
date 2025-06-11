# Laravel Docker Template - Setup Guide

This guide walks you through setting up the Laravel Docker template for a new or existing Laravel project.

## 📋 Prerequisites

- **OrbStack** (or Docker Desktop) installed and running
- A Laravel project (new or existing)
- Basic knowledge of Docker and Laravel

## 🚀 Step-by-Step Setup

### 1. Copy Template to Your Project

Copy the entire `laravel-docker-template` directory to your Laravel project root:

```bash
# Navigate to your Laravel project
cd /path/to/your/laravel/project

# Copy template files (replace source path with actual path)
cp -r /path/to/laravel-docker-template/* .
cp -r /path/to/laravel-docker-template/.* . 2>/dev/null || true

# Make the script executable
chmod +x docker-dev.sh
```

### 2. Initial Setup

Run the setup command to configure your project:

```bash
./docker-dev.sh setup
```

This will:
1. **Prompt for configuration** (project name, ports, database settings)
2. **Generate all required files** from templates
3. **Build Docker containers**
4. **Start all services**
5. **Run database migrations**

### 3. Configuration Prompts

During setup, you'll be asked for:

```
Project name [your_project_name]: my_blog
App name [Laravel App]: My Blog
App port [8080]: 8080
MySQL port [3306]: 3306
PHPMyAdmin port [8081]: 8081
Mailhog web port [8025]: 8025
Database name [my_blog_db]: my_blog_db
Database username [my_blog_user]: my_blog_user
Database password [my_blog_password]: secret123
```

**Tips:**
- Use different ports for each project to avoid conflicts
- Keep project names simple (lowercase, underscores only)
- Remember your database credentials

### 4. Post-Setup Steps

After successful setup:

1. **Generate Application Key** (if needed):
   ```bash
   ./docker-dev.sh artisan key:generate
   ```

2. **Install Dependencies** (if not already done):
   ```bash
   ./docker-dev.sh composer install
   ./docker-dev.sh npm install
   ```

3. **Run Migrations** (if you have existing migrations):
   ```bash
   ./docker-dev.sh artisan migrate
   ```

4. **Build Frontend Assets**:
   ```bash
   ./docker-dev.sh npm run dev
   ```

### 5. Access Your Application

- **Laravel App**: http://localhost:8080 (or your configured port)
- **PHPMyAdmin**: http://localhost:8081
- **Mailhog**: http://localhost:8025

## 🔧 Common Configuration Scenarios

### Multiple Projects Setup

For running multiple Laravel projects simultaneously:

**Project A** (`blog`):
```
PROJECT_NAME=blog
APP_PORT=8080
PHPMYADMIN_PORT=8081
MAILHOG_WEB_PORT=8025
```

**Project B** (`ecommerce`):
```
PROJECT_NAME=ecommerce
APP_PORT=8090
PHPMYADMIN_PORT=8091
MAILHOG_WEB_PORT=8035
```

### Custom Domain Setup

To use a custom domain (e.g., `blog.local`):

1. Edit `/etc/hosts`:
   ```
   127.0.0.1 blog.local
   ```

2. Update `docker/config.env`:
   ```
   APP_URL=http://blog.local:8080
   ```

3. Regenerate files:
   ```bash
   ./docker-dev.sh generate
   ./docker-dev.sh restart
   ```

## 🛠️ Development Workflow

### Daily Commands

```bash
# Start development
./docker-dev.sh start

# View logs
./docker-dev.sh logs

# Run artisan commands
./docker-dev.sh artisan migrate
./docker-dev.sh artisan make:controller ProductController

# Install packages
./docker-dev.sh composer require spatie/laravel-permission
./docker-dev.sh npm install lodash

# Run tests
./docker-dev.sh test

# Stop development
./docker-dev.sh stop
```

### Database Operations

```bash
# Connect to MySQL
./docker-dev.sh mysql

# Fresh database
./docker-dev.sh artisan migrate:fresh --seed

# Backup database
docker exec PROJECT_NAME_mysql mysqldump -u USERNAME -pPASSWORD DATABASE > backup.sql

# Restore database
cat backup.sql | docker exec -i PROJECT_NAME_mysql mysql -u USERNAME -pPASSWORD DATABASE
```

### Debugging

```bash
# Container shell access
./docker-dev.sh shell

# View specific service logs
./docker-dev.sh app-logs
docker compose logs mysql
docker compose logs redis

# Check container status
./docker-dev.sh status
```

## 🔄 File Structure After Setup

```
your-laravel-project/
├── docker/
│   ├── dev/
│   │   ├── Dockerfile
│   │   ├── 000-default.conf
│   │   ├── php.ini
│   │   ├── supervisord.conf
│   │   ├── entrypoint.sh          # Generated from template
│   │   ├── env.example            # Generated from template
│   │   └── mysql/
│   │       └── init.sql           # Generated from template
│   └── config.env                 # Your project configuration
├── .vscode/
│   └── launch.json                # VS Code debug config
├── .dockerignore
├── docker-compose.yml             # Generated from template
├── docker-dev.sh                  # Development helper script
└── [your Laravel files...]
```

## 🚨 Troubleshooting

### Port Conflicts

**Error**: `Port 8080 is already in use`

**Solution**:
1. Edit `docker/config.env` and change `APP_PORT`
2. Run `./docker-dev.sh generate`
3. Run `./docker-dev.sh restart`

### Permission Issues

**Error**: `Permission denied` for storage/logs

**Solution**:
```bash
./docker-dev.sh shell
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
exit
```

### Database Connection Issues

**Error**: `SQLSTATE[HY000] [2002] Connection refused`

**Solution**:
1. Check if MySQL container is running: `./docker-dev.sh status`
2. Check MySQL logs: `docker compose logs mysql`
3. Reset the environment: `./docker-dev.sh fresh`

### Container Build Failures

**Error**: Build fails with dependency issues

**Solution**:
```bash
# Clean rebuild
./docker-dev.sh cleanup
./docker-dev.sh setup
```

### VS Code Debugging Not Working

**Solution**:
1. Install PHP Debug extension
2. Ensure Xdebug is enabled: `./docker-dev.sh shell`, then `php -m | grep xdebug`
3. Check `.vscode/launch.json` configuration
4. Set breakpoints and start debugging

## 📚 Advanced Usage

### Custom Services

To add more services (e.g., Elasticsearch), edit `docker-compose.yml.template` before running setup.

### Production Deployment

This template is for **development only**. For production:
1. Create separate production Docker files
2. Use environment-specific configurations
3. Implement proper security measures
4. Use managed services for databases

### Backup and Migration

```bash
# Export project configuration
cp docker/config.env project-config-backup.env

# Full project backup
tar -czf project-backup.tar.gz . --exclude=node_modules --exclude=vendor
```

## 🔗 Useful Commands

```bash
# Quick status check
./docker-dev.sh status

# Restart specific service
docker compose restart app

# View real-time logs
./docker-dev.sh logs | grep ERROR

# Clean Docker system
docker system prune -a

# Update composer packages
./docker-dev.sh composer update

# Clear all Laravel caches
./docker-dev.sh artisan optimize:clear
```

## 📞 Support

If you encounter issues:
1. Check this troubleshooting guide
2. Review Docker and container logs
3. Ensure all prerequisites are met
4. Try a fresh setup with `./docker-dev.sh fresh` 