#!/bin/bash

# Laravel Docker Development Helper Script
# Reusable template for any Laravel project

set -e

COMPOSE_FILE="docker-compose.yml"
CONFIG_FILE="docker/config.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_help() {
    echo -e "${BLUE}Laravel Docker Development Helper${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Initial setup (configure, generate files, build, start)"
    echo "  configure - Configure project (edit docker/config.env)"
    echo "  generate  - Generate files from templates"
    echo "  start     - Start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  build     - Build/rebuild containers"
    echo "  logs      - View logs from all services"
    echo "  app-logs  - View application container logs"
    echo "  mysql     - Connect to MySQL database"
    echo "  redis     - Connect to Redis"
    echo "  shell     - Open shell in app container"
    echo "  artisan   - Run artisan commands"
    echo "  composer  - Run composer commands"
    echo "  npm       - Run npm commands"
    echo "  test      - Run PHPUnit tests"
    echo "  fresh     - Fresh install (rebuild and reset database)"
    echo "  status    - Show container status"
    echo "  cleanup   - Remove containers, volumes, and images"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 artisan migrate"
    echo "  $0 composer install"
    echo "  $0 npm run dev"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        exit 1
    fi
}

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file $CONFIG_FILE not found. Run '$0 configure' first."
        exit 1
    fi
    
    # Load configuration variables
    source "$CONFIG_FILE"
    
    # Set defaults if not specified
    PROJECT_NAME=${PROJECT_NAME:-"laravel_app"}
    APP_NAME=${APP_NAME:-"Laravel App"}
    APP_PORT=${APP_PORT:-8080}
    MYSQL_PORT=${MYSQL_PORT:-3306}
    REDIS_PORT=${REDIS_PORT:-6379}
    PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
    MAILHOG_SMTP_PORT=${MAILHOG_SMTP_PORT:-1025}
    MAILHOG_WEB_PORT=${MAILHOG_WEB_PORT:-8025}
    DB_DATABASE=${DB_DATABASE:-"laravel_db"}
    DB_USERNAME=${DB_USERNAME:-"laravel_user"}
    DB_PASSWORD=${DB_PASSWORD:-"laravel_password"}
    DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"root_password"}
    APP_URL=${APP_URL:-"http://localhost:${APP_PORT}"}
    APP_ENV=${APP_ENV:-"local"}
    APP_DEBUG=${APP_DEBUG:-"true"}
}

configure_project() {
    print_status "Configuring project..."
    
    # Create config directory if it doesn't exist
    mkdir -p docker
    
    # Create config file if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        print_status "Creating configuration file..."
        
        # Get current directory name as default project name
        DEFAULT_PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
        
        echo "Please provide configuration for your Laravel project:"
        
        read -p "Project name [$DEFAULT_PROJECT_NAME]: " PROJECT_NAME
        PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_PROJECT_NAME}
        
        read -p "App name [Laravel App]: " APP_NAME
        APP_NAME=${APP_NAME:-"Laravel App"}
        
        read -p "App port [8080]: " APP_PORT
        APP_PORT=${APP_PORT:-8080}
        
        read -p "MySQL port [3306]: " MYSQL_PORT
        MYSQL_PORT=${MYSQL_PORT:-3306}
        
        read -p "PHPMyAdmin port [8081]: " PHPMYADMIN_PORT
        PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
        
        read -p "Mailhog web port [8025]: " MAILHOG_WEB_PORT
        MAILHOG_WEB_PORT=${MAILHOG_WEB_PORT:-8025}
        
        read -p "Database name [${PROJECT_NAME}_db]: " DB_DATABASE
        DB_DATABASE=${DB_DATABASE:-"${PROJECT_NAME}_db"}
        
        read -p "Database username [${PROJECT_NAME}_user]: " DB_USERNAME
        DB_USERNAME=${DB_USERNAME:-"${PROJECT_NAME}_user"}
        
        read -p "Database password [${PROJECT_NAME}_password]: " DB_PASSWORD
        DB_PASSWORD=${DB_PASSWORD:-"${PROJECT_NAME}_password"}
        
        # Write configuration file
        cat > "$CONFIG_FILE" << EOF
# Laravel Docker Template Configuration
PROJECT_NAME=$PROJECT_NAME
APP_NAME="$APP_NAME"

# Port Configuration
APP_PORT=$APP_PORT
MYSQL_PORT=$MYSQL_PORT
REDIS_PORT=6379
PHPMYADMIN_PORT=$PHPMYADMIN_PORT
MAILHOG_SMTP_PORT=1025
MAILHOG_WEB_PORT=$MAILHOG_WEB_PORT

# Database Configuration
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
DB_ROOT_PASSWORD=root_password

# Application Configuration
APP_URL=http://localhost:$APP_PORT
APP_ENV=local
APP_DEBUG=true
EOF
        
        print_status "Configuration saved to $CONFIG_FILE"
    else
        print_warning "Configuration file already exists. Edit $CONFIG_FILE manually if needed."
        echo ""
        echo "Current configuration:"
        cat "$CONFIG_FILE"
    fi
}

generate_files() {
    print_status "Generating files from templates..."
    
    load_config
    
    # Function to replace placeholders in template files
    replace_placeholders() {
        local template_file="$1"
        local output_file="$2"
        
        if [ ! -f "$template_file" ]; then
            print_error "Template file $template_file not found"
            return 1
        fi
        
        cp "$template_file" "$output_file"
        
        # Replace placeholders
        sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$output_file"
        sed -i.bak "s/{{APP_NAME}}/$APP_NAME/g" "$output_file"
        sed -i.bak "s/{{APP_PORT}}/$APP_PORT/g" "$output_file"
        sed -i.bak "s/{{MYSQL_PORT}}/$MYSQL_PORT/g" "$output_file"
        sed -i.bak "s/{{REDIS_PORT}}/$REDIS_PORT/g" "$output_file"
        sed -i.bak "s/{{PHPMYADMIN_PORT}}/$PHPMYADMIN_PORT/g" "$output_file"
        sed -i.bak "s/{{MAILHOG_SMTP_PORT}}/$MAILHOG_SMTP_PORT/g" "$output_file"
        sed -i.bak "s/{{MAILHOG_WEB_PORT}}/$MAILHOG_WEB_PORT/g" "$output_file"
        sed -i.bak "s/{{DB_DATABASE}}/$DB_DATABASE/g" "$output_file"
        sed -i.bak "s/{{DB_USERNAME}}/$DB_USERNAME/g" "$output_file"
        sed -i.bak "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" "$output_file"
        sed -i.bak "s/{{DB_ROOT_PASSWORD}}/$DB_ROOT_PASSWORD/g" "$output_file"
        sed -i.bak "s|{{APP_URL}}|$APP_URL|g" "$output_file"
        sed -i.bak "s/{{APP_ENV}}/$APP_ENV/g" "$output_file"
        sed -i.bak "s/{{APP_DEBUG}}/$APP_DEBUG/g" "$output_file"
        
        # Remove backup files
        rm -f "$output_file.bak"
    }
    
    # Generate docker-compose.yml
    if [ -f "docker-compose.yml.template" ]; then
        replace_placeholders "docker-compose.yml.template" "$COMPOSE_FILE"
        print_status "Generated $COMPOSE_FILE"
    fi
    
    # Generate entrypoint.sh
    if [ -f "docker/dev/entrypoint.sh.template" ]; then
        replace_placeholders "docker/dev/entrypoint.sh.template" "docker/dev/entrypoint.sh"
        chmod +x docker/dev/entrypoint.sh
        print_status "Generated docker/dev/entrypoint.sh"
    fi
    
    # Generate MySQL init script
    if [ -f "docker/dev/mysql/init.sql.template" ]; then
        replace_placeholders "docker/dev/mysql/init.sql.template" "docker/dev/mysql/init.sql"
        print_status "Generated docker/dev/mysql/init.sql"
    fi
    
    # Generate Laravel .env file
    if [ -f "docker/dev/env.example.template" ]; then
        replace_placeholders "docker/dev/env.example.template" "docker/dev/env.example"
        
        # Copy to .env if it doesn't exist
        if [ ! -f ".env" ]; then
            cp "docker/dev/env.example" ".env"
            print_status "Generated .env file from template"
            print_warning "Please update your .env file with your actual application key"
        else
            print_warning ".env file already exists. Consider updating it with values from docker/dev/env.example"
        fi
    fi
}

setup_environment() {
    print_status "Setting up environment..."
    
    # Create necessary directories
    mkdir -p storage/logs
    mkdir -p bootstrap/cache
    
    print_status "Environment setup completed"
}

case "$1" in
    setup)
        check_docker
        configure_project
        generate_files
        setup_environment
        print_status "Building and starting containers..."
        docker compose -f $COMPOSE_FILE build
        docker compose -f $COMPOSE_FILE up -d
        print_status "Waiting for containers to be ready..."
        sleep 10
        load_config
        print_status "Setup completed!"
        print_status "Application URL: $APP_URL"
        print_status "PHPMyAdmin URL: http://localhost:$PHPMYADMIN_PORT"
        print_status "Mailhog URL: http://localhost:$MAILHOG_WEB_PORT"
        ;;
    configure)
        configure_project
        ;;
    generate)
        generate_files
        ;;
    start)
        check_docker
        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker compose file not found. Run '$0 setup' first."
            exit 1
        fi
        print_status "Starting containers..."
        docker compose -f $COMPOSE_FILE up -d
        ;;
    stop)
        check_docker
        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker compose file not found. Run '$0 setup' first."
            exit 1
        fi
        print_status "Stopping containers..."
        docker compose -f $COMPOSE_FILE down
        ;;
    restart)
        check_docker
        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker compose file not found. Run '$0 setup' first."
            exit 1
        fi
        print_status "Restarting containers..."
        docker compose -f $COMPOSE_FILE restart
        ;;
    build)
        check_docker
        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker compose file not found. Run '$0 setup' first."
            exit 1
        fi
        print_status "Building containers..."
        docker compose -f $COMPOSE_FILE build
        ;;
    logs)
        check_docker
        docker compose -f $COMPOSE_FILE logs -f
        ;;
    app-logs)
        check_docker
        docker compose -f $COMPOSE_FILE logs -f app
        ;;
    mysql)
        check_docker
        load_config
        print_status "Connecting to MySQL..."
        docker compose -f $COMPOSE_FILE exec mysql mysql -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE
        ;;
    redis)
        check_docker
        print_status "Connecting to Redis..."
        docker compose -f $COMPOSE_FILE exec redis redis-cli
        ;;
    shell)
        check_docker
        print_status "Opening shell in app container..."
        docker compose -f $COMPOSE_FILE exec app /bin/bash
        ;;
    artisan)
        check_docker
        shift
        docker compose -f $COMPOSE_FILE exec app php artisan "$@"
        ;;
    composer)
        check_docker
        shift
        docker compose -f $COMPOSE_FILE exec app composer "$@"
        ;;
    npm)
        check_docker
        shift
        docker compose -f $COMPOSE_FILE exec app npm "$@"
        ;;
    test)
        check_docker
        print_status "Running PHPUnit tests..."
        docker compose -f $COMPOSE_FILE exec app php artisan test
        ;;
    fresh)
        check_docker
        load_config
        print_warning "This will destroy all data and rebuild everything!"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Stopping and removing containers..."
            docker compose -f $COMPOSE_FILE down -v
            print_status "Rebuilding containers..."
            docker compose -f $COMPOSE_FILE build --no-cache
            print_status "Starting fresh environment..."
            docker compose -f $COMPOSE_FILE up -d
        fi
        ;;
    status)
        check_docker
        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker compose file not found. Run '$0 setup' first."
            exit 1
        fi
        print_status "Container status:"
        docker compose -f $COMPOSE_FILE ps
        ;;
    cleanup)
        check_docker
        load_config
        print_warning "This will remove all containers, volumes, and images for this project!"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleaning up..."
            docker compose -f $COMPOSE_FILE down -v --rmi all
            docker system prune -f
        fi
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        print_error "Unknown command: $1"
        print_help
        exit 1
        ;;
esac 