#!/bin/bash

echo "=== System Security Audit ==="
echo "Timestamp: $(date)"
echo ""

echo "→ Checking unusual SUID/SGID files..."
find / -perm /6000 -type f -ls 2>/dev/null | head -20
echo ""

echo "→ Checking active network connections..."
ss -tulpn 2>/dev/null || netstat -tulpn
echo ""

echo "→ Checking listening ports..."
lsof -i -P -n | grep LISTEN 2>/dev/null || echo "lsof not available"
echo ""

echo "→ Recent failed authentication attempts..."
if command -v journalctl &> /dev/null; then
    journalctl -u ssh -u sshd --since "24 hours ago" | grep -i "failed\|failure" | tail -20
else
    grep -i "failed\|failure" /var/log/auth.log 2>/dev/null | tail -20 || echo "Auth logs not accessible"
fi
echo ""

echo "→ Checking for suspicious cron jobs..."
ls -la /etc/cron.* 2>/dev/null
echo ""

echo "→ Checking loaded kernel modules..."
lsmod | head -20
echo ""

echo "→ Checking system users with shell access..."
grep -E ":/bin/(bash|sh|zsh|fish)" /etc/passwd
echo ""

echo "→ Checking for files modified in last 24 hours in critical directories..."
find /etc /bin /sbin /usr/bin /usr/sbin -type f -mtime -1 2>/dev/null | head -20
echo ""

echo "→ Checking process list for suspicious activity..."
ps aux --sort=-%cpu | head -20
echo ""

echo "=== Audit Complete ==="
