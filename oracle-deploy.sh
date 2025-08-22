#!/bin/bash

# Oracle Cloud Free Tier Deployment Script for Brick Hill
# Optimized for 1GB RAM AMD instance or 4GB+ ARM instance
# FREE FOREVER hosting solution!

set -e

echo "🔥 Oracle Cloud Free Tier - Brick Hill Deployment"
echo "=================================================="
echo "💰 Cost: FREE FOREVER!"
echo "🎯 Target: <100 concurrent users"
echo "🖥️  Optimized for minimal resources"
echo ""

# Detect system architecture and resources
ARCH=$(uname -m)
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')

echo "🔍 System Info:"
echo "   Architecture: $ARCH"
echo "   Total RAM: ${TOTAL_RAM}MB"
echo ""

if [ "$TOTAL_RAM" -lt 1000 ]; then
    echo "⚠️  Warning: Very low RAM detected. Applying ultra-light configuration."
    ULTRA_LIGHT=true
else
    ULTRA_LIGHT=false
fi

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages for minimal setup
echo "📦 Installing essential packages..."
if [ "$ULTRA_LIGHT" = true ]; then
    # Minimal installation for very low RAM
    sudo apt install -y nginx php8.1-fpm php8.1-sqlite3 php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-bcmath sqlite3 git unzip curl nodejs npm
    echo "🔧 Ultra-light mode: Skipping MySQL, Redis, and heavy packages"
else
    # Standard installation for 2GB+ RAM
    sudo apt install -y nginx mysql-server php8.1-fpm php8.1-mysql php8.1-sqlite3 php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-bcmath sqlite3 git unzip curl nodejs npm
fi

# Install Composer
echo "📦 Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p /var/www/brickhill
sudo chown -R $USER:www-data /var/www/brickhill

# Copy application files
echo "📋 Copying application files..."
cp -r . /var/www/brickhill/
cd /var/www/brickhill

# Use the new improved Oracle Cloud environment configuration
echo "⚙️ Creating optimized environment configuration..."
cp .env.oracle .env

# Update dynamic values
sed -i "s|APP_URL=http://localhost|APP_URL=http://$(curl -s ifconfig.me)|" .env
sed -i "s|MAINTENANCE_KEY=oracle_maintenance_secret|MAINTENANCE_KEY=oracle_maintenance_$(openssl rand -hex 16)|" .env

# Install PHP dependencies with optimizations
echo "📦 Installing PHP dependencies (optimized)..."
composer install --no-dev --optimize-autoloader --no-interaction

# Install minimal Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install --production

# Build production assets (minimal)
echo "🏗️ Building optimized assets..."
npm run production

# Create SQLite database
echo "🗄️ Setting up SQLite database..."
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite

# Generate application key
echo "🔑 Generating application key..."
php artisan key:generate

# Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force --no-interaction

# Create storage link
echo "🔗 Setting up storage link..."
php artisan storage:link

# Set up Laravel Passport (if needed)
echo "🔐 Setting up authentication..."
if php artisan route:list | grep -q passport; then
    php artisan passport:install --force
fi

# Optimize Laravel for production
echo "🚀 Optimizing Laravel for production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions
echo "🔒 Setting up permissions..."
sudo chown -R www-data:www-data /var/www/brickhill
sudo chmod -R 755 /var/www/brickhill
sudo chmod -R 775 /var/www/brickhill/storage
sudo chmod -R 775 /var/www/brickhill/bootstrap/cache
sudo chmod -R 775 /var/www/brickhill/database

# Configure Nginx for Oracle Cloud
echo "🌐 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/brickhill << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/brickhill/public;
    index index.php index.html index.htm;

    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Gzip compression for better performance
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { 
        access_log off; 
        log_not_found off; 
        expires 1y;
        add_header Cache-Control "public, immutable";
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
        
        # Increase timeouts for Oracle Cloud
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 180s;
        fastcgi_read_timeout 180s;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Limit file upload size (Oracle Cloud friendly)
    client_max_body_size 10M;
}
EOF

# Remove default Nginx site and enable ours
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/brickhill /etc/nginx/sites-enabled/

# Configure PHP-FPM for low memory usage
echo "🔧 Optimizing PHP-FPM for Oracle Cloud..."
sudo tee /etc/php/8.1/fpm/pool.d/brickhill.conf << EOF
[brickhill]
user = www-data
group = www-data
listen = /var/run/php/php8.1-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Optimize for Oracle Cloud Free Tier
pm = static
pm.max_children = 3
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 2
pm.max_requests = 500

; Memory optimizations
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 120
php_admin_value[upload_max_filesize] = 10M
php_admin_value[post_max_size] = 10M
EOF

# Test configurations
echo "🧪 Testing configurations..."
sudo nginx -t
sudo php-fpm8.1 -t

# Start services
echo "🚀 Starting services..."
sudo systemctl enable nginx php8.1-fpm
sudo systemctl restart nginx php8.1-fpm

# Set up basic firewall (Oracle Cloud compatible)
echo "🛡️ Setting up firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

# Create maintenance script
echo "📝 Creating maintenance script..."
cat > /var/www/brickhill/oracle-maintenance.sh << 'EOF'
#!/bin/bash
# Oracle Cloud maintenance script

echo "🔧 Running Oracle Cloud maintenance..."

cd /var/www/brickhill

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Rebuild optimized caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clean up logs (keep space free)
find storage/logs -name "*.log" -mtime +7 -delete

# Optimize database (SQLite)
php artisan db:vacuum

# Check disk space
df -h

echo "✅ Maintenance complete!"
EOF

chmod +x /var/www/brickhill/oracle-maintenance.sh

# Set up cron job for maintenance
echo "⏰ Setting up automated maintenance..."
(crontab -l 2>/dev/null; echo "0 2 * * 0 /var/www/brickhill/oracle-maintenance.sh >> /var/log/brickhill-maintenance.log 2>&1") | crontab -

# Get external IP for final message
EXTERNAL_IP=$(curl -s ifconfig.me)

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "===================="
echo "💰 Cost: FREE (Oracle Cloud Always Free Tier)"
echo "🌐 Your site: http://$EXTERNAL_IP"
echo "📊 Resources: $(free -m | awk 'NR==2{print $2}')MB RAM available"
echo "🗄️ Database: SQLite (no MySQL overhead)"
echo "⚡ Cache: File-based (no Redis overhead)"
echo ""
echo "📝 NEXT STEPS:"
echo "1. Update Oracle Cloud security list to allow HTTP (port 80)"
echo "2. Optional: Get a free domain from Freenom or DuckDNS"
echo "3. Optional: Set up Cloudflare for SSL and CDN (free)"
echo "4. Monitor with: sudo systemctl status nginx php8.1-fpm"
echo ""
echo "🔧 MAINTENANCE:"
echo "- Run weekly: /var/www/brickhill/oracle-maintenance.sh"
echo "- Check logs: tail -f /var/www/brickhill/storage/logs/laravel.log"
echo "- Update system: sudo apt update && sudo apt upgrade"
echo ""
echo "✅ Your Brick Hill site is now running FREE on Oracle Cloud!"
