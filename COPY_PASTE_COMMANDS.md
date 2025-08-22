# 🚀 INSTANT DEPLOYMENT - Copy & Paste Commands

## For Your Oracle Cloud Server (192.9.162.99)

### 🎯 **ONE-COMMAND DEPLOYMENT** (Recommended)

**Just copy and paste this single command on your server:**

```bash
cd ~ && git clone https://github.com/Saumodunn/Brick-Hill.git && cd Brick-Hill && chmod +x instant-deploy.sh && ./instant-deploy.sh
```

**That's it!** ☝️ This one command does everything automatically in ~15 minutes.

---

## 🔗 **Connection Commands**

### **Connect to Your Server:**
```bash
# Replace "path-to-your-key.key" with your actual SSH key file
ssh -i "C:\Users\andrews crack house\Downloads\ssh-key-*.key" ubuntu@192.9.162.99
```

### **If SSH Connection Fails:**
```bash
# Try with verbose output to see what's wrong
ssh -i "C:\Users\andrews crack house\Downloads\ssh-key-*.key" -v ubuntu@192.9.162.99
```

---

## 🛡️ **Oracle Cloud Firewall Configuration**

After deployment, you need to open port 80 in Oracle Cloud Console:

### **Step-by-Step:**
1. Go to **Oracle Cloud Console**
2. **Menu** → **Networking** → **Virtual Cloud Networks** 
3. Click your **VCN name**
4. Click **Security Lists**
5. Click **Default Security List**
6. Click **Add Ingress Rules**
7. **Copy and paste these values:**

```
Source Type: CIDR
Source CIDR: 0.0.0.0/0
IP Protocol: TCP  
Destination Port Range: 80
Description: HTTP for Brick Hill
```

8. Click **Add Ingress Rules**

---

## 🔧 **Useful Management Commands**

**Copy these for later use:**

### **Check Site Status:**
```bash
curl -I http://192.9.162.99
```

### **Monitor Resources:**
```bash
cd /var/www/brickhill && ./monitor.sh
```

### **Check Logs:**
```bash
tail -f /var/www/brickhill/storage/logs/laravel.log
```

### **Restart Services (if needed):**
```bash
sudo systemctl restart nginx php8.1-fpm
```

### **Check Service Status:**
```bash
sudo systemctl status nginx php8.1-fpm
```

---

## 🚨 **Troubleshooting Commands**

### **If Site Won't Load:**
```bash
# Check if services are running
sudo systemctl status nginx php8.1-fpm

# Check nginx configuration
sudo nginx -t

# Check PHP processes
ps aux | grep php
```

### **If Out of Memory:**
```bash
# Check memory usage
free -h

# Restart PHP to free memory
sudo systemctl restart php8.1-fpm
```

### **If Out of Disk Space:**
```bash
# Check disk usage
df -h

# Clean up logs
sudo find /var/log -name "*.log" -mtime +7 -delete
```

---

## 📊 **Performance Check Commands**

```bash
# System resources
free -h && df -h

# Active connections
ss -tuln | grep :80

# Top processes
top -o %MEM
```

---

## 🎯 **Your Complete Setup Process:**

1. **Connect to server**: `ssh -i "your-key.key" ubuntu@192.9.162.99`

2. **Run deployment**: `cd ~ && git clone https://github.com/Saumodunn/Brick-Hill.git && cd Brick-Hill && chmod +x instant-deploy.sh && ./instant-deploy.sh`

3. **Open Oracle Cloud firewall** (port 80)

4. **Visit your site**: `http://192.9.162.99`

5. **Done!** 🎉

---

## 📞 **Quick Reference**

| Action | Command |
|--------|---------|
| **Deploy** | `./instant-deploy.sh` |
| **Monitor** | `./monitor.sh` |
| **Check logs** | `tail -f storage/logs/laravel.log` |
| **Restart** | `sudo systemctl restart nginx php8.1-fpm` |
| **Status** | `curl -I http://192.9.162.99` |

**Your site will be live at: http://192.9.162.99** 🌐

**Cost: $0 AUD/year forever** 💰

**Performance: 20-50 concurrent users** 📈
