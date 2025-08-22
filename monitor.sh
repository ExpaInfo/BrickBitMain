#!/bin/bash

# Oracle Cloud Performance Monitor for BrickBit
# Monitors resource usage and alerts when limits are reached

echo "📊 Oracle Cloud - BrickBit Performance Monitor"
echo "=============================================="
echo "⏰ $(date)"
echo ""

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check system information
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
USED_RAM=$(free -m | awk 'NR==2{printf "%.0f", $3}')
RAM_PERCENT=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')

DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
DISK_USED=$(df -h / | awk 'NR==2{print $3}')
DISK_PERCENT=$(df / | awk 'NR==2{print $5}' | sed 's/%//')

LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

echo "🖥️  SYSTEM RESOURCES"
echo "==================="

# RAM Usage
echo -n "💾 RAM Usage: ${USED_RAM}MB / ${TOTAL_RAM}MB (${RAM_PERCENT}%) "
if [ $RAM_PERCENT -lt 70 ]; then
    echo -e "${GREEN}[OK]${NC}"
elif [ $RAM_PERCENT -lt 85 ]; then
    echo -e "${YELLOW}[WARNING]${NC}"
else
    echo -e "${RED}[CRITICAL]${NC}"
fi

# Disk Usage
echo -n "💿 Disk Usage: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PERCENT}%) "
if [ $DISK_PERCENT -lt 70 ]; then
    echo -e "${GREEN}[OK]${NC}"
elif [ $DISK_PERCENT -lt 85 ]; then
    echo -e "${YELLOW}[WARNING]${NC}"
else
    echo -e "${RED}[CRITICAL]${NC}"
fi

# Load Average
echo -n "⚡ Load Average: ${LOAD_AVG} "
if (( $(echo "$LOAD_AVG < 0.7" | bc -l) )); then
    echo -e "${GREEN}[OK]${NC}"
elif (( $(echo "$LOAD_AVG < 1.0" | bc -l) )); then
    echo -e "${YELLOW}[WARNING]${NC}"
else
    echo -e "${RED}[CRITICAL]${NC}"
fi

echo ""
echo "🌐 WEB SERVICES"
echo "==============="

# Check Nginx status
if systemctl is-active --quiet nginx; then
    echo -e "🔸 Nginx: ${GREEN}[RUNNING]${NC}"
else
    echo -e "🔸 Nginx: ${RED}[STOPPED]${NC}"
fi

# Check PHP-FPM status
if systemctl is-active --quiet php8.1-fpm; then
    echo -e "🔸 PHP-FPM: ${GREEN}[RUNNING]${NC}"
else
    echo -e "🔸 PHP-FPM: ${RED}[STOPPED]${NC}"
fi

# Check if website responds
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
echo -n "🔸 Website Response: "
if [ "$RESPONSE_CODE" = "200" ]; then
    echo -e "${GREEN}[OK - $RESPONSE_CODE]${NC}"
else
    echo -e "${RED}[ERROR - $RESPONSE_CODE]${NC}"
fi

echo ""
echo "📁 STORAGE ANALYSIS"
echo "==================="

# Laravel logs size
LARAVEL_LOGS_SIZE=$(du -sh /var/www/brickbit/storage/logs 2>/dev/null | cut -f1)
echo "🔸 Laravel Logs: ${LARAVEL_LOGS_SIZE}"

# System logs size
SYSTEM_LOGS_SIZE=$(du -sh /var/log 2>/dev/null | cut -f1)
echo "🔸 System Logs: ${SYSTEM_LOGS_SIZE}"

# SQLite database size
SQLITE_SIZE=$(du -sh /var/www/brickbit/database/database.sqlite 2>/dev/null | cut -f1)
echo "🔸 SQLite Database: ${SQLITE_SIZE}"

echo ""
echo "🔗 NETWORK STATUS"
echo "=================="

# Check active connections
ACTIVE_CONNECTIONS=$(ss -tuln | grep -E ':80|:443' | wc -l)
echo "🔸 Active HTTP/HTTPS connections: ${ACTIVE_CONNECTIONS}"

# Check external connectivity
echo -n "🔸 External connectivity: "
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAILED]${NC}"
fi

echo ""
echo "⚠️  ALERTS & RECOMMENDATIONS"
echo "=============================="

ALERTS=0

# RAM Alert
if [ $RAM_PERCENT -gt 85 ]; then
    echo -e "${RED}🚨 HIGH MEMORY USAGE (${RAM_PERCENT}%)${NC}"
    echo "   → Restart PHP-FPM: sudo systemctl restart php8.1-fpm"
    ALERTS=$((ALERTS + 1))
fi

# Disk Alert
if [ $DISK_PERCENT -gt 85 ]; then
    echo -e "${RED}🚨 HIGH DISK USAGE (${DISK_PERCENT}%)${NC}"
    echo "   → Clean logs: /var/www/brickbit/oracle-maintenance.sh"
    ALERTS=$((ALERTS + 1))
fi

# Load Alert
if (( $(echo "$LOAD_AVG > 1.0" | bc -l) )); then
    echo -e "${RED}🚨 HIGH CPU LOAD (${LOAD_AVG})${NC}"
    echo "   → Check processes: top -o %CPU"
    ALERTS=$((ALERTS + 1))
fi

# Service Alerts
if ! systemctl is-active --quiet nginx; then
    echo -e "${RED}🚨 NGINX NOT RUNNING${NC}"
    echo "   → Start Nginx: sudo systemctl start nginx"
    ALERTS=$((ALERTS + 1))
fi

if ! systemctl is-active --quiet php8.1-fpm; then
    echo -e "${RED}🚨 PHP-FPM NOT RUNNING${NC}"
    echo "   → Start PHP-FPM: sudo systemctl start php8.1-fpm"
    ALERTS=$((ALERTS + 1))
fi

# Website Alert
if [ "$RESPONSE_CODE" != "200" ]; then
    echo -e "${RED}🚨 WEBSITE NOT RESPONDING${NC}"
    echo "   → Check logs: tail -f /var/www/brickbit/storage/logs/laravel.log"
    ALERTS=$((ALERTS + 1))
fi

if [ $ALERTS -eq 0 ]; then
    echo -e "${GREEN}✅ All systems normal!${NC}"
fi

echo ""
echo "📈 PERFORMANCE TIPS"
echo "==================="

# Provide optimization suggestions based on current usage
if [ $RAM_PERCENT -gt 60 ]; then
    echo "💡 RAM optimization tips:"
    echo "   → Restart PHP-FPM weekly: sudo systemctl restart php8.1-fpm"
    echo "   → Consider reducing PHP-FPM max_children in /etc/php/8.1/fpm/pool.d/brickbit.conf"
fi

if [ $DISK_PERCENT -gt 60 ]; then
    echo "💡 Disk optimization tips:"
    echo "   → Run maintenance script weekly: /var/www/brickbit/oracle-maintenance.sh"
    echo "   → Enable log rotation for Laravel logs"
fi

echo ""
echo "🔧 QUICK ACTIONS"
echo "================"
echo "Restart services:    sudo systemctl restart nginx php8.1-fpm"
echo "Run maintenance:     /var/www/brickbit/oracle-maintenance.sh"
echo "Check error logs:    tail -f /var/www/brickbit/storage/logs/laravel.log"
echo "View system logs:    sudo journalctl -f"
echo ""

# Save monitoring data for trend analysis
TIMESTAMP=$(date +%s)
echo "$TIMESTAMP,$RAM_PERCENT,$DISK_PERCENT,$LOAD_AVG,$RESPONSE_CODE" >> /var/log/brickbit-metrics.csv

echo "📊 Monitor completed. Metrics saved to /var/log/brickbit-metrics.csv"
