# Brick Hill Local Development Setup for Windows
# This script helps set up the Laravel application locally for testing

Write-Host "🚀 Setting up Brick Hill locally..." -ForegroundColor Green

# Check if PHP is installed
if (!(Get-Command php -ErrorAction SilentlyContinue)) {
    Write-Host "❌ PHP is not installed. Please install PHP 8.1+ first." -ForegroundColor Red
    Write-Host "Download from: https://windows.php.net/download/" -ForegroundColor Yellow
    exit 1
}

# Check if Composer is installed
if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Composer is not installed. Please install Composer first." -ForegroundColor Red
    Write-Host "Download from: https://getcomposer.org/download/" -ForegroundColor Yellow
    exit 1
}

# Check if Node.js is installed
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Install PHP dependencies
Write-Host "📦 Installing PHP dependencies..." -ForegroundColor Blue
composer install

# Install Node.js dependencies
Write-Host "📦 Installing Node.js dependencies..." -ForegroundColor Blue
npm install

# Build frontend assets
Write-Host "🏗️ Building frontend assets..." -ForegroundColor Blue
npm run development

# Generate application key if not set
Write-Host "🔑 Generating application key..." -ForegroundColor Blue
php artisan key:generate

Write-Host "✅ Local setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps for local development:" -ForegroundColor Yellow
Write-Host "1. Set up a local database (MySQL/MariaDB)" -ForegroundColor White
Write-Host "2. Update .env with your database credentials" -ForegroundColor White
Write-Host "3. Run: php artisan migrate" -ForegroundColor White
Write-Host "4. Run: php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host "🌐 For production deployment, see HOSTING_GUIDE.md" -ForegroundColor Cyan
