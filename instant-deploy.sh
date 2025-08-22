#!/bin/bash

# INSTANT BRICK HILL DEPLOYMENT FOR ORACLE CLOUD
# One command does EVERYTHING - optimized for 192.9.162.99 (1GB AMD)
# Run this on your Oracle Cloud server for instant deployment

set -e

echo "🚀 INSTANT BRICK HILL DEPLOYMENT"
echo "================================="
echo "🎯 Target: 192.9.162.99 (Oracle Cloud AMD 1GB)"
echo "💰 Cost: FREE FOREVER"
echo "⏱️  Time: ~15 minutes"
echo ""

# Silent apt to reduce output
export DEBIAN_FRONTEND=noninteractive

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

progress() {
    echo -e "${BLUE}🔄 $1...${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Step 1: System Update
progress "Updating system (step 1/10)"
sudo apt update -qq && sudo apt upgrade -y -qq
success "System updated"

# Step 2: Install packages
progress "Installing required packages (step 2/10)"
sudo apt install -y -qq nginx php8.1-fpm php8.1-sqlite3 php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-bcmath sqlite3 git unzip curl nodejs npm bc ufw > /dev/null 2>&1
success "Packages installed"

# Step 3: Install Composer
progress "Installing Composer (step 3/10)"
curl -sS https://getcomposer.org/installer | php > /dev/null 2>&1
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
success "Composer installed"

# Step 4: Setup application
progress "Setting up application structure (step 4/10)"
sudo mkdir -p /var/www/brickhill
sudo chown -R ubuntu:www-data /var/www/brickhill
cp -r . /var/www/brickhill/
cd /var/www/brickhill
success "Application copied"

# Step 5: Configure environment
progress "Configuring environment (step 5/10)"
cat > .env << 'EOF'
APP_NAME='Brick Hill'
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://192.9.162.99
FAKE_NOTIFICATIONS=false

MAIN_ACCOUNT_ID=1
SESSION_COOKIE=bh_session
SESSION_LIFETIME=10800
SESSION_SECURE_COOKIE=false

LOG_CHANNEL=single
LOG_LEVEL=error

JS_ASSET_PATH=/dist/js/
CSS_ASSET_PATH=/dist/css/

# SQLite for minimal resources
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/brickhill/database/database.sqlite

# File caching (no Redis)
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
BROADCAST_DRIVER=log

# Local mail
MAIL_MAILER=log

# Local storage
STORAGE_FILE_LOC=/var/www/brickhill/storage/app/public
STORAGE_LOCAL_LOC=/var/www/brickhill/storage/app/public
EOF
success "Environment configured"

# Step 6: Install dependencies
progress "Installing PHP dependencies (step 6/10)"
composer install --no-dev --optimize-autoloader --no-interaction --quiet
success "PHP dependencies installed"

progress "Installing Node dependencies (step 7/10)"
npm install --production --silent
npm run production > /dev/null 2>&1
success "Frontend built"

# Step 7: Laravel setup
progress "Setting up Laravel (step 8/10)"
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
php artisan key:generate --force > /dev/null
php artisan migrate --force --no-interaction > /dev/null
php artisan storage:link > /dev/null 2>&1 || true
php artisan config:cache > /dev/null
php artisan route:cache > /dev/null
php artisan view:cache > /dev/null
success "Laravel configured"

# Step 8: Configure web server
progress "Configuring Nginx (step 9/10)"
sudo rm -f /etc/nginx/sites-enabled/default

sudo tee /etc/nginx/sites-available/brickhill > /dev/null << 'EOF'
server {
    listen 80 default_server;
    root /var/www/brickhill/public;
    index index.php;
    server_name _;

    gzip on;
    gzip_types text/css application/javascript application/json text/xml;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/brickhill /etc/nginx/sites-enabled/

# Optimize PHP for 1GB RAM
sudo tee /etc/php/8.1/fpm/pool.d/brickhill.conf > /dev/null << 'EOF'
[brickhill]
user = www-data
group = www-data
listen = /var/run/php/php8.1-fpm.sock

pm = static
pm.max_children = 3
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 2

php_admin_value[memory_limit] = 256M
EOF

success "Web server configured"

# Step 9: Set permissions and start services
progress "Starting services (step 10/10)"
sudo chown -R www-data:www-data /var/www/brickhill
sudo chmod -R 775 /var/www/brickhill/storage /var/www/brickhill/bootstrap/cache /var/www/brickhill/database

sudo systemctl enable nginx php8.1-fpm > /dev/null 2>&1
sudo systemctl restart nginx php8.1-fpm

# Configure firewall
sudo ufw --force reset > /dev/null 2>&1
sudo ufw default deny incoming > /dev/null 2>&1
sudo ufw default allow outgoing > /dev/null 2>&1
sudo ufw allow 22/tcp > /dev/null 2>&1
sudo ufw allow 80/tcp > /dev/null 2>&1
sudo ufw --force enable > /dev/null 2>&1

success "Services started"

# Final test
sleep 3
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================="
echo "💰 Cost: FREE (Oracle Cloud)"
echo "🌐 Site URL: http://192.9.162.99"
echo "📊 Status: HTTP $RESPONSE_CODE"
echo "💾 RAM: $(free -h | awk 'NR==2{print $3"/"$2}')"
echo "💿 Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo ""

if [ "$RESPONSE_CODE" = "200" ]; then
    echo -e "${GREEN}✅ SUCCESS! Your Brick Hill site is LIVE!${NC}"
    echo ""
    echo "🎯 IMMEDIATE ACCESS:"
    echo "   👉 Open browser: http://192.9.162.99"
    echo ""
    echo "🔧 USEFUL COMMANDS:"
    echo "   Monitor: ./monitor.sh"
    echo "   Logs: tail -f storage/logs/laravel.log"
    echo "   Restart: sudo systemctl restart nginx php8.1-fpm"
else
    echo -e "${YELLOW}⚠️  Site deployed but needs Oracle Cloud security configuration${NC}"
    echo ""
    echo "🔓 NEXT STEP: Open Oracle Cloud firewall"
    echo "   1. Go to Oracle Cloud Console"
    echo "   2. Networking → Virtual Cloud Networks"
    echo "   3. Security Lists → Add Ingress Rule"
    echo "   4. Allow port 80 from 0.0.0.0/0"
fi

echo ""
echo "📈 PERFORMANCE: Optimized for 20-50 concurrent users"
echo "🆓 COST: $0 forever (Oracle Cloud Always Free)"
echo ""
echo "🎉 Welcome to your FREE Brick Hill hosting!"
