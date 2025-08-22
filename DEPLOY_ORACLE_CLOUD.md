# 🚀 Deploy BrickBit on Oracle Cloud FREE

## Step 1: Create Oracle Cloud Account (5 minutes)

1. Go to **https://cloud.oracle.com**
2. Click **"Start for free"**
3. Fill out the form with your real details
4. Verify your email and phone number
5. Add a credit card (for verification - you won't be charged)
6. Choose **"Australia East (Sydney)"** as your region

## Step 2: Create a Free Instance (3 minutes)

1. **Login** to Oracle Cloud Console
2. Click **Menu (☰)** → **Compute** → **Instances**
3. Click **"Create Instance"**
4. Configure your instance:
   ```
   Name: brickbit-server
   Image: Ubuntu 22.04 Minimal
   Shape: VM.Standard.E2.1.Micro (Always Free - 1GB RAM)
   OR
   Shape: VM.Standard.A1.Flex (Free - 4 CPUs, 24GB RAM if available)
   Boot Volume: 47GB (maximum free)
   ```
5. **SSH Keys**: Click "Generate a key pair for me"
6. **SAVE THE PRIVATE KEY** to your computer (you'll need it!)
7. Click **"Create"**
8. Wait 2-3 minutes for it to provision
9. **Copy the Public IP address** from the instance details

## Step 3: Connect to Your Server

### Windows (using PowerShell):
```powershell
# Replace YOUR_PRIVATE_KEY.key with the file you downloaded
# Replace YOUR_PUBLIC_IP with your instance's IP
ssh -i "C:\path\to\YOUR_PRIVATE_KEY.key" ubuntu@YOUR_PUBLIC_IP
```

### If you get a permission error:
```powershell
# Fix key permissions (Windows)
icacls "C:\path\to\YOUR_PRIVATE_KEY.key" /inheritance:r
icacls "C:\path\to\YOUR_PRIVATE_KEY.key" /grant:r "%username%:R"
```

## Step 4: Install Docker (2 minutes)

Once connected to your server, run these commands:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install -y docker-compose

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Restart session (or logout/login)
newgrp docker
```

## Step 5: Deploy BrickBit (5 minutes)

```bash
# Clone your repository
git clone https://github.com/ExpaInfo/BrickBitMain.git
cd BrickBitMain

# Create production environment file
cp .env.example .env

# Edit the environment file
nano .env
```

**Edit these important settings in .env:**
```env
APP_NAME='BrickBit'
APP_ENV=production
APP_DEBUG=false
APP_URL=http://YOUR_PUBLIC_IP

# Database settings (Docker will handle these)
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=brickbit_prod
DB_USERNAME=root
DB_PASSWORD=your_secure_password_here

# Cache and sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
REDIS_HOST=redis

# Mail settings (optional)
MAIL_MAILER=log
```

**Save the file:** Press `Ctrl+X`, then `Y`, then `Enter`

## Step 6: Start the Application (3 minutes)

```bash
# Build and start all services
docker-compose up -d --profile all-services

# Generate application key
docker-compose exec app php artisan key:generate

# Run database migrations
docker-compose exec app php artisan migrate --force

# Create storage link
docker-compose exec app php artisan storage:link

# Install Passport (for API authentication)
docker-compose exec app php artisan passport:install
```

## Step 7: Configure Oracle Cloud Firewall (2 minutes)

1. In Oracle Cloud Console, go to **Networking** → **Virtual Cloud Networks**
2. Click your VCN → **Security Lists** → **Default Security List**
3. Click **"Add Ingress Rules"**
4. Add this rule:
   ```
   Source Type: CIDR
   Source CIDR: 0.0.0.0/0
   IP Protocol: TCP
   Destination Port Range: 80
   Description: HTTP for BrickBit
   ```
5. Click **"Add Ingress Rules"**

## Step 8: Test Your Site! 🎉

Open your browser and go to: `http://YOUR_PUBLIC_IP`

You should see BrickBit running!

---

## 🔧 Useful Commands

### Check if everything is running:
```bash
docker-compose ps
```

### View logs:
```bash
# Application logs
docker-compose logs app

# Database logs  
docker-compose logs db

# All logs
docker-compose logs
```

### Restart services:
```bash
docker-compose restart
```

### Stop everything:
```bash
docker-compose down
```

### Update the application:
```bash
git pull
docker-compose down
docker-compose up -d --profile all-services --build
```

---

## 🆘 Troubleshooting

### Site won't load?
1. Check if containers are running: `docker-compose ps`
2. Check Oracle Cloud firewall rules (port 80 must be open)
3. Check logs: `docker-compose logs app`

### Out of memory?
- Restart containers: `docker-compose restart`
- Use 1GB AMD instance: Less concurrent users but stable

### Database issues?
```bash
# Reset database
docker-compose exec app php artisan migrate:fresh --force
```

---

## 💰 Cost: $0 AUD/year forever!

Your BrickBit site is now running on Oracle Cloud's Always Free tier!

**Performance expectations:**
- **1GB AMD instance**: 10-30 concurrent users
- **24GB ARM instance**: 100+ concurrent users

**Your site URL:** `http://YOUR_PUBLIC_IP`
