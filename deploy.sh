#!/bin/bash

# BrickBit Deployment Script for Ubuntu/Debian VPS
# This script sets up the entire environment for hosting BrickBit

set -e

echo "🚀 Starting BrickBit deployment..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "📦 Installing required packages..."
sudo apt install -y nginx mysql-server redis-server php8.1-fpm php8.1-mysql php8.1-redis php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-bcmath php8.1-tokenizer composer nodejs npm git unzip curl

# Install Composer if not already installed
if ! command -v composer &> /dev/null; then
    echo "📦 Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
fi

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p /var/www/brickbit
sudo chown -R $USER:www-data /var/www/brickbit

# Copy application files
echo "📋 Copying application files..."
cp -r . /var/www/brickbit/
cd /var/www/brickbit

# Install PHP dependencies
echo "📦 Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader

# Install Node.js dependencies and build assets
echo "🏗️ Building frontend assets..."
npm install
npm run production

# Set up database
echo "🗄️ Setting up database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS brickbit_production;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'brickbit_user'@'localhost' IDENTIFIED BY 'secure_password_here';"
sudo mysql -e "GRANT ALL PRIVILEGES ON brickbit_production.* TO 'brickbit_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Set up environment file
echo "⚙️ Configuring environment..."
cp .env.example .env
sed -i 's/APP_ENV=local/APP_ENV=production/' .env
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env
sed -i 's/DB_DATABASE=testbh/DB_DATABASE=brickbit_production/' .env
sed -i 's/DB_USERNAME=root/DB_USERNAME=brickbit_user/' .env
sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=secure_password_here/' .env
sed -i 's|APP_URL=http://\[domain\].test|APP_URL=https://yourdomain.com|' .env

# Generate application key
echo "🔑 Generating application key..."
php artisan key:generate

# Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# Set up storage link
echo "🔗 Setting up storage link..."
php artisan storage:link

# Set up Laravel Passport
echo "🔐 Setting up Laravel Passport..."
php artisan passport:install

# Set proper permissions
echo "🔒 Setting up permissions..."
sudo chown -R $USER:www-data /var/www/brickbit
sudo chmod -R 775 /var/www/brickbit/storage
sudo chmod -R 775 /var/www/brickbit/bootstrap/cache

# Configure Nginx
echo "🌐 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/brickbit << EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/brickbit/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    client_max_body_size 20M;
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/brickbit /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Set up SSL with Let's Encrypt (optional but recommended)
echo "🔒 Setting up SSL certificate..."
sudo apt install -y certbot python3-certbot-nginx
# sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Set up cron job for Laravel scheduler
echo "⏰ Setting up Laravel scheduler..."
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/brickbit && php artisan schedule:run >> /dev/null 2>&1") | crontab -

# Set up supervisor for queue workers (optional)
sudo apt install -y supervisor
sudo tee /etc/supervisor/conf.d/brickbit-worker.conf << EOF
[program:brickbit-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/brickbit/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/brickbit/storage/logs/worker.log
stopwaitsecs=3600
EOF

sudo supervisorctl reread
sudo supervisorctl update

echo "✅ Deployment complete!"
echo "📝 Next steps:"
echo "1. Update your domain DNS to point to this server"
echo "2. Update the APP_URL in /var/www/brickbit/.env"
echo "3. Set up your reCAPTCHA keys"
echo "4. Configure your mail settings"
echo "5. Run: sudo certbot --nginx -d yourdomain.com"
