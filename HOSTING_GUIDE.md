# BrickBit Hosting Guide - Under $40 AUD

## 🎯 Recommended Hosting Solution: Vultr VPS

**Cost Breakdown:**
- Vultr High Performance 2GB: $12 USD/month (~$18 AUD)
- Domain name (optional): ~$15 AUD/year
- **Total monthly cost: ~$18 AUD** ✅

## 🚀 Step-by-Step Deployment

### 1. Get a VPS Server

1. **Sign up at Vultr.com**
2. **Choose server location** (Sydney, Australia for best local performance)
3. **Select**: High Performance - 2GB RAM, 1 CPU, 50GB NVMe
4. **OS**: Ubuntu 22.04 LTS
5. **Deploy the server**

### 2. Connect to Your Server

```bash
# Replace YOUR_SERVER_IP with the actual IP
ssh root@YOUR_SERVER_IP
```

### 3. Upload and Run Deployment Script

```bash
# On your server, download the BrickBit code
git clone https://github.com/Saumodunn/Brick-Hill.git
cd Brick-Hill

# Make the deployment script executable
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

### 4. Configure Your Domain

**Option A: Buy a domain (~$15 AUD/year)**
- Namecheap.com or Google Domains
- Point A record to your server IP

**Option B: Use a free subdomain**
- Use services like DuckDNS or NoIP
- Point to your server IP

### 5. Update Configuration

Edit `/var/www/brickbit/.env`:
```bash
sudo nano /var/www/brickbit/.env
```

Update these values:
```
APP_URL=https://yourdomain.com
DB_PASSWORD=your_secure_password
RECAPTCHA_SECRET=your_recaptcha_secret
RECAPTCHA_PUBLIC=your_recaptcha_public
```

### 6. Enable SSL

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## 💰 Alternative Budget Options

### Option 1: Shared Hosting (~$10-15 AUD/month)
- **SiteGround** or **A2 Hosting**
- Laravel-ready shared hosting
- **Pros**: Managed, easier
- **Cons**: Limited resources, may not support all features

### Option 2: DigitalOcean Droplet (~$9 AUD/month)
- $6 USD Basic Droplet
- 1GB RAM (minimal but workable)
- **Pros**: Cheaper
- **Cons**: Less performance

### Option 3: Oracle Cloud Free Tier (FREE!)
- Always free tier with decent specs
- 1GB RAM ARM instance or smaller AMD
- **Pros**: Free forever
- **Cons**: Limited, can be complex to set up

## 🔧 Performance Optimizations for Budget Hosting

### 1. Enable Caching
```bash
# In your .env file
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

### 2. Optimize Composer
```bash
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3. Database Optimization
```bash
# Add to your .env
DB_CHARSET=utf8mb4
DB_COLLATION=utf8mb4_unicode_ci
```

## 📋 Pre-Deployment Checklist

- [ ] Server provisioned and accessible
- [ ] Domain configured (or free subdomain)
- [ ] reCAPTCHA keys obtained from Google
- [ ] Email service configured (Gmail SMTP is free)
- [ ] SSL certificate installed
- [ ] Database secured with strong password
- [ ] Firewall configured (UFW)

## 🛡️ Security Best Practices

1. **Change default passwords**
2. **Set up UFW firewall**:
   ```bash
   sudo ufw allow OpenSSH
   sudo ufw allow 'Nginx Full'
   sudo ufw enable
   ```
3. **Regular updates**:
   ```bash
   sudo apt update && sudo apt upgrade
   ```
4. **Monitor logs**:
   ```bash
   tail -f /var/www/brickbit/storage/logs/laravel.log
   ```

## 🆘 Common Issues & Solutions

### Issue: 500 Internal Server Error
```bash
# Check Laravel logs
tail -f /var/www/brickbit/storage/logs/laravel.log

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Fix permissions
sudo chown -R www-data:www-data /var/www/brickbit
sudo chmod -R 755 /var/www/brickbit
sudo chmod -R 775 /var/www/brickbit/storage
sudo chmod -R 775 /var/www/brickbit/bootstrap/cache
```

### Issue: Database Connection Error
```bash
# Test database connection
php artisan tinker
# In tinker: DB::select('SELECT 1');
```

## 📊 Monthly Cost Summary

| Service | Cost (AUD) |
|---------|------------|
| Vultr VPS 2GB | $18 |
| Domain (yearly/12) | $1.25 |
| **Total** | **$19.25/month** |

**Remaining budget: $20.75 AUD for additional services or upgrades!**

## 🎉 You're Ready to Launch!

Once deployed, your BrickBit site will be accessible at your domain with:
- ✅ Full Laravel functionality
- ✅ Vue.js frontend
- ✅ MySQL database
- ✅ Redis caching
- ✅ SSL encryption
- ✅ Professional hosting setup

Need help with any specific customizations or have questions about the deployment process? Let me know!
