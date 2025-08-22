#!/bin/bash

# Complete Oracle Cloud Setup Script for Brick Hill
# Run this after creating your Oracle Cloud instance

echo "🌟 Oracle Cloud Complete Setup for Brick Hill"
echo "=============================================="
echo "💰 Cost: FREE FOREVER"
echo "⏱️  Estimated setup time: 15-20 minutes"
echo ""

# Check if running as root or with sudo access
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Please run this script as ubuntu user, not root"
    echo "Usage: ./oracle-setup-complete.sh"
    exit 1
fi

# Test sudo access
if ! sudo -n true 2>/dev/null; then
    echo "🔐 This script requires sudo access. Please enter your password when prompted."
fi

echo "🚀 Starting complete setup..."

# Update system
echo ""
echo "📦 Step 1/8: Updating system..."
sudo apt update && sudo apt upgrade -y

# Install all required packages
echo ""
echo "📦 Step 2/8: Installing required packages..."
sudo apt install -y \
    nginx \
    php8.1-fpm \
    php8.1-sqlite3 \
    php8.1-mysql \
    php8.1-curl \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    php8.1-bcmath \
    php8.1-intl \
    sqlite3 \
    git \
    unzip \
    curl \
    nodejs \
    npm \
    bc \
    ufw

# Install Composer
echo ""
echo "📦 Step 3/8: Installing Composer..."
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
fi

# Create application directory and set permissions
echo ""
echo "📁 Step 4/8: Setting up application structure..."
sudo mkdir -p /var/www/brickhill
sudo chown -R ubuntu:www-data /var/www/brickhill

# Copy application files
echo ""
echo "📋 Step 5/8: Deploying application files..."
cp -r . /var/www/brickhill/
cd /var/www/brickhill

# Set up optimized environment
echo ""
echo "⚙️ Step 6/8: Configuring environment..."
cp .env.oracle .env

# Update with server IP
SERVER_IP=$(curl -s ifconfig.me)
sed -i "s|APP_URL=http://localhost|APP_URL=http://$SERVER_IP|" .env

# Install dependencies and build
echo ""
echo "📦 Step 7/8: Installing dependencies and building..."

# PHP dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# Node dependencies (minimal for Oracle Cloud)
npm install --production --silent

# Build production assets
npm run production

# Laravel setup
echo ""
echo "🔧 Setting up Laravel..."

# Create SQLite database
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite

# Generate application key
php artisan key:generate --force

# Run migrations
php artisan migrate --force --no-interaction

# Create storage link
php artisan storage:link

# Set up Passport if needed
if php artisan route:list 2>/dev/null | grep -q passport; then
    php artisan passport:install --force
fi

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Configure Nginx
echo ""
echo "🌐 Step 8/8: Configuring web server..."

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Create optimized Nginx configuration
sudo tee /etc/nginx/sites-available/brickhill > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/brickhill/public;
    index index.php index.html;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { 
        access_log off; 
        log_not_found off; 
    }
    
    location = /robots.txt { 
        access_log off; 
        log_not_found off; 
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_connect_timeout 60;
        fastcgi_send_timeout 180;
        fastcgi_read_timeout 180;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    client_max_body_size 10M;
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/brickhill /etc/nginx/sites-enabled/

# Configure PHP-FPM for low memory
sudo tee /etc/php/8.1/fpm/pool.d/brickhill.conf > /dev/null << EOF
[brickhill]
user = www-data
group = www-data
listen = /var/run/php/php8.1-fpm.sock
listen.owner = www-data
listen.group = www-data

pm = static
pm.max_children = 3
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 2
pm.max_requests = 500

php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 120
php_admin_value[upload_max_filesize] = 10M
php_admin_value[post_max_size] = 10M
EOF

# Test configurations
echo "🧪 Testing configurations..."
sudo nginx -t
sudo php-fpm8.1 -t

# Set final permissions
echo "🔒 Setting final permissions..."
sudo chown -R www-data:www-data /var/www/brickhill
sudo chmod -R 755 /var/www/brickhill
sudo chmod -R 775 /var/www/brickhill/storage
sudo chmod -R 775 /var/www/brickhill/bootstrap/cache
sudo chmod -R 775 /var/www/brickhill/database

# Make scripts executable
chmod +x monitor.sh
chmod +x oracle-maintenance.sh

# Set up firewall
echo "🛡️ Configuring firewall..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Start services
echo "🚀 Starting services..."
sudo systemctl enable nginx php8.1-fpm
sudo systemctl restart nginx php8.1-fpm

# Set up automated maintenance
echo "⏰ Setting up automated maintenance..."
(crontab -l 2>/dev/null; echo "0 2 * * 0 /var/www/brickhill/oracle-maintenance.sh >> /var/log/brickhill-maintenance.log 2>&1") | crontab -

# Final status check
echo ""
echo "🔍 Final status check..."
sleep 3

# Test website
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$RESPONSE_CODE" = "200" ]; then
    SITE_STATUS="✅ WORKING"
else
    SITE_STATUS="❌ ERROR ($RESPONSE_CODE)"
fi

# Get system info
RAM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
DISK_USAGE=$(df / | awk 'NR==2{print $5}')

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================="
echo "💰 Cost: FREE (Oracle Cloud Always Free Tier)"
echo "🌐 Your site: http://$SERVER_IP"
echo "📊 Site status: $SITE_STATUS"
echo "💾 RAM usage: ${RAM_USAGE}%"
echo "💿 Disk usage: ${DISK_USAGE}"
echo ""
echo "📝 IMMEDIATE NEXT STEPS:"
echo "1. 🔓 Open Oracle Cloud Security List (allow port 80)"
echo "2. 🌐 Test your site: http://$SERVER_IP"
echo "3. 📖 Read ORACLE_CLOUD_GUIDE.md for full instructions"
echo ""
echo "🔧 USEFUL COMMANDS:"
echo "Monitor performance:  ./monitor.sh"
echo "Run maintenance:      ./oracle-maintenance.sh"
echo "Check logs:          tail -f storage/logs/laravel.log"
echo "Restart services:    sudo systemctl restart nginx php8.1-fpm"
echo ""
echo "🎯 Your Brick Hill site is ready for up to 100 users - FREE FOREVER!"

# Create a status file
echo "Deployment completed on $(date)" > /var/www/brickhill/DEPLOYMENT_STATUS.txt
echo "Server IP: $SERVER_IP" >> /var/www/brickhill/DEPLOYMENT_STATUS.txt
echo "Site status: $SITE_STATUS" >> /var/www/brickhill/DEPLOYMENT_STATUS.txt
