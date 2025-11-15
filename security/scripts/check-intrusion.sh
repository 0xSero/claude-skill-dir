#!/bin/bash

REPORT_FILE="intrusion-check-$(date +%Y%m%d-%H%M%S).txt"

echo "Intrusion Detection Check - $(date)" | tee "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Check 1: Unusual network connections
echo "[*] Checking for unusual network connections..." | tee -a "$REPORT_FILE"
SUSPICIOUS_IPS=$(ss -tn | awk '{print $5}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u | grep -v "127.0.0.1")
if [ -n "$SUSPICIOUS_IPS" ]; then
    echo "Active external connections to:" | tee -a "$REPORT_FILE"
    echo "$SUSPICIOUS_IPS" | tee -a "$REPORT_FILE"
else
    echo "No suspicious connections detected" | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

# Check 2: Hidden files in /tmp
echo "[*] Checking for hidden files in /tmp..." | tee -a "$REPORT_FILE"
find /tmp -name ".*" -type f 2>/dev/null | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Check 3: Processes running from /tmp or /dev/shm
echo "[*] Checking for processes running from temporary locations..." | tee -a "$REPORT_FILE"
lsof 2>/dev/null | grep -E '/tmp|/dev/shm' | grep -v "\.X11" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Check 4: Check for rootkit signatures (basic)
echo "[*] Basic rootkit detection..." | tee -a "$REPORT_FILE"
if command -v chkrootkit &> /dev/null; then
    sudo chkrootkit | grep -i "warning\|infected" | tee -a "$REPORT_FILE"
else
    echo "chkrootkit not installed - skipping" | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

# Check 5: Recently modified system binaries
echo "[*] Checking for recently modified system binaries..." | tee -a "$REPORT_FILE"
find /bin /sbin /usr/bin /usr/sbin -type f -mtime -7 2>/dev/null | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Check 6: Unusual scheduled tasks
echo "[*] Checking for unusual scheduled tasks..." | tee -a "$REPORT_FILE"
cat /etc/crontab 2>/dev/null | tee -a "$REPORT_FILE"
ls -la /etc/cron.* 2>/dev/null | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Check 7: Failed login attempts
echo "[*] Recent failed login attempts..." | tee -a "$REPORT_FILE"
if command -v journalctl &> /dev/null; then
    journalctl --since "7 days ago" | grep -i "failed password" | tail -20 | tee -a "$REPORT_FILE"
else
    grep -i "failed password" /var/log/auth.log 2>/dev/null | tail -20 | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

echo "========================================" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE" | tee -a "$REPORT_FILE"
