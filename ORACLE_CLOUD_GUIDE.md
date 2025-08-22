# Oracle Cloud FREE Hosting Guide for Brick Hill

## 🎯 **COST: $0 AUD/year - FREE FOREVER!**

Oracle Cloud offers a genuinely free tier that never expires. Perfect for your budget!

## 🚀 **Quick Start Overview**

1. **Create Oracle Cloud account** (5 minutes)
2. **Launch free instance** (2 minutes) 
3. **Run deployment script** (15 minutes)
4. **Configure security** (3 minutes)
5. **Access your site** (immediately)

**Total setup time: ~25 minutes**

---

## 📋 **Step 1: Create Oracle Cloud Account**

### **1.1 Sign Up**
1. Go to **https://cloud.oracle.com**
2. Click **"Start for free"**
3. Fill in your details:
   - **Country**: Australia
   - **Name**: Your real name
   - **Email**: Valid email address
   - **Phone**: Your real phone number

### **1.2 Verification**
- ✅ Email verification (check inbox)
- ✅ Phone verification (SMS code)
- ✅ Credit card verification (FREE - no charges!)

**⚠️ Important**: You need a valid credit card for verification, but you'll **never be charged** for free tier usage.

### **1.3 Account Setup**
- Choose **"Australia East (Sydney)"** as your region
- Complete the verification process
- Wait for account activation (~2-10 minutes)

---

## 🖥️ **Step 2: Launch Your Free Instance**

### **2.1 Access Compute Dashboard**
1. **Login** to Oracle Cloud Console
2. **Navigate**: Menu → Compute → Instances
3. **Click**: "Create Instance"

### **2.2 Choose Your Instance Type**

**🎯 RECOMMENDED: AMD Standard (Always Available)**
```
Name: brickhill-server
Image: Ubuntu 22.04 Minimal
Shape: VM.Standard.E2.1.Micro
- 1 CPU (AMD)
- 1GB RAM 
- 47GB Boot Volume
Cost: FREE FOREVER
```

**🏆 IDEAL: ARM Ampere (If Available)**
```
Name: brickhill-server
Image: Ubuntu 22.04 Minimal  
Shape: VM.Standard.A1.Flex
- 4 CPUs (ARM)
- 24GB RAM
- 200GB Boot Volume
Cost: FREE FOREVER
```

### **2.3 Configure Instance**
1. **Boot volume**: 47GB (free limit)
2. **Network**: Use default VCN
3. **SSH Keys**: Generate new key pair
4. **Save private key** to your computer!

### **2.4 Launch Instance**
- Click **"Create"**
- Wait 1-2 minutes for provisioning
- Note down the **Public IP address**

---

## 🔧 **Step 3: Deploy Brick Hill**

### **3.1 Connect to Your Instance**

**Windows (PowerShell):**
```powershell
# Replace YOUR_PRIVATE_KEY.key and YOUR_IP with actual values
ssh -i "C:\path\to\YOUR_PRIVATE_KEY.key" ubuntu@YOUR_IP
```

**Windows (PuTTY):**
1. Convert .key to .ppk using PuTTYgen
2. Connect using PuTTY with the .ppk file

### **3.2 Download Brick Hill Code**
```bash
# On your Oracle Cloud server
git clone https://github.com/Saumodunn/Brick-Hill.git
cd Brick-Hill
```

### **3.3 Run Automatic Deployment**
```bash
# Make script executable
chmod +x oracle-deploy.sh

# Run deployment (takes ~15 minutes)
./oracle-deploy.sh
```

**The script automatically:**
- ✅ Installs all required software
- ✅ Optimizes for Oracle Cloud free tier
- ✅ Sets up SQLite database
- ✅ Configures Nginx web server
- ✅ Builds frontend assets
- ✅ Sets up security and monitoring

---

## 🛡️ **Step 4: Configure Security**

### **4.1 Oracle Cloud Security List**
1. **Go to**: Networking → Virtual Cloud Networks
2. **Click**: Your VCN → Security Lists → Default Security List
3. **Add Ingress Rule**:
   ```
   Source: 0.0.0.0/0
   IP Protocol: TCP
   Destination Port Range: 80
   Description: HTTP for Brick Hill
   ```
4. **Add Ingress Rule** (for HTTPS later):
   ```
   Source: 0.0.0.0/0
   IP Protocol: TCP
   Destination Port Range: 443
   Description: HTTPS for Brick Hill
   ```

### **4.2 Ubuntu Firewall**
The deployment script already configured this, but to verify:
```bash
sudo ufw status
# Should show: 22/tcp, 80/tcp, 443/tcp ALLOW
```

---

## 🌐 **Step 5: Access Your Site**

### **5.1 Test Your Site**
Open in browser: `http://YOUR_PUBLIC_IP`

You should see the Brick Hill homepage! 🎉

### **5.2 Get a Free Domain (Optional)**

**Option A: DuckDNS (Recommended)**
1. Go to **https://www.duckdns.org/**
2. Sign up with GitHub/Google
3. Create subdomain: `yourbrickhill.duckdns.org`
4. Point to your Oracle Cloud IP

**Option B: Freenom**
1. Go to **https://freenom.com**
2. Register free domain (.tk, .ml, .ga)
3. Configure DNS A record to your IP

---

## 📊 **Performance & Monitoring**

### **Resource Usage (1GB AMD Instance)**
- **Concurrent users**: ~20-50
- **RAM usage**: ~600-800MB
- **CPU usage**: ~30-60%
- **Storage**: ~3-5GB used

### **Resource Usage (24GB ARM Instance)**
- **Concurrent users**: ~200-500
- **RAM usage**: ~2-4GB
- **CPU usage**: ~10-20%
- **Storage**: ~3-5GB used

### **Monitoring Commands**
```bash
# Check resource usage
free -h
df -h
top

# Check services
sudo systemctl status nginx php8.1-fpm

# Check logs
tail -f /var/www/brickhill/storage/logs/laravel.log
sudo tail -f /var/log/nginx/error.log
```

---

## 🔧 **Maintenance**

### **Weekly Maintenance** (Automated)
The deployment script sets up automatic weekly maintenance:
```bash
# Manual maintenance
/var/www/brickhill/oracle-maintenance.sh
```

### **Updates**
```bash
# System updates
sudo apt update && sudo apt upgrade -y

# Restart services after updates  
sudo systemctl restart nginx php8.1-fpm
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

**🔍 Issue: Can't access website**
```bash
# Check if services are running
sudo systemctl status nginx php8.1-fpm

# Check Oracle Cloud Security List (most common issue)
# Make sure port 80 is open in Oracle Cloud Console
```

**🔍 Issue: 500 Internal Server Error**
```bash
# Check Laravel logs
tail -f /var/www/brickhill/storage/logs/laravel.log

# Check file permissions
sudo chown -R www-data:www-data /var/www/brickhill
sudo chmod -R 775 /var/www/brickhill/storage
```

**🔍 Issue: Running out of space**
```bash
# Check disk usage
df -h

# Clean up logs
sudo find /var/log -type f -name "*.log" -mtime +7 -delete
find /var/www/brickhill/storage/logs -name "*.log" -mtime +3 -delete

# Clean up package cache
sudo apt autoremove
sudo apt autoclean
```

**🔍 Issue: High memory usage**
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head

# Restart PHP-FPM to free memory
sudo systemctl restart php8.1-fpm
```

---

## 🌟 **Upgrading Later**

### **Add More Features When You Grow**

**Add MySQL Database:**
```bash
sudo apt install mysql-server
# Update .env to use mysql instead of sqlite
```

**Add Redis Cache:**
```bash
sudo apt install redis-server
# Update .env: CACHE_DRIVER=redis
```

**Add SSL Certificate:**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

**Add Email Service:**
- Use Gmail SMTP (free for low volume)
- Or Mailgun free tier (10,000 emails/month)

---

## 💰 **Cost Analysis**

### **Oracle Cloud Free Tier Limits**
- **Compute**: 2 x AMD instances OR 1 x 4-core ARM instance
- **Storage**: 200GB block storage
- **Network**: 10TB bandwidth/month
- **Database**: 20GB Autonomous Database

### **What This Means**
- ✅ **Your Brick Hill site**: Uses ~5GB storage, ~1TB bandwidth
- ✅ **Room for growth**: You could run 5-10 similar sites
- ✅ **Never expires**: Unlike AWS/Google 12-month trials
- ✅ **No surprise bills**: Free tier has hard limits, no overages

---

## 🎉 **Success! Your Site is Live**

Your Brick Hill site is now:
- ✅ **Hosted FREE** on Oracle Cloud
- ✅ **Accessible globally** via your public IP
- ✅ **Optimized** for performance on free tier
- ✅ **Monitored** with automatic maintenance
- ✅ **Secure** with proper firewall setup

**What's next?**
1. **Get a domain name** for better branding
2. **Add SSL certificate** for HTTPS
3. **Set up email service** for user notifications
4. **Monitor usage** and optimize as needed

**Questions or issues?** Check the troubleshooting section above or let me know!

---

## 📞 **Quick Reference**

```bash
# Connect to server
ssh -i "your-key.key" ubuntu@YOUR_IP

# Check site status
curl http://YOUR_IP

# Restart services
sudo systemctl restart nginx php8.1-fpm

# View logs
tail -f /var/www/brickhill/storage/logs/laravel.log

# Run maintenance
/var/www/brickhill/oracle-maintenance.sh
```

🎯 **Your Brick Hill site is now running 100% FREE on Oracle Cloud!**
