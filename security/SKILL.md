# Security Analysis & Protection Expert

Expert in security analysis, reverse engineering, intrusion detection, and system hardening. Specializes in using tools like Ghidra, forensics utilities, and security monitoring to ensure system safety and investigate potential threats.

## When to use this skill

- Analyzing suspicious files or binaries
- Reverse engineering applications
- Checking for system intrusions or compromises
- Performing security audits on systems
- Investigating security incidents
- Hardening system security
- Analyzing malware or suspicious code
- Setting up intrusion detection systems
- Reviewing system logs for anomalies

## Core Expertise

### Reverse Engineering & Binary Analysis
- **Ghidra**: NSA's software reverse engineering framework
  - Decompile binaries to pseudo-C code
  - Analyze program structure and control flow
  - Identify vulnerabilities in compiled code
  - Create and apply function signatures
  - Script analysis with Ghidra's Python API

- **Binary Analysis Tools**:
  - `strings` - Extract readable strings from binaries
  - `file` - Identify file types
  - `hexdump` / `xxd` - Hex dump analysis
  - `objdump` - Display object file information
  - `readelf` - ELF file analysis
  - `nm` - List symbols from object files
  - `ldd` - Show shared library dependencies

### Intrusion Detection & Forensics
- **System Monitoring**:
  - Check running processes for anomalies (`ps`, `top`, `htop`)
  - Monitor network connections (`netstat`, `ss`, `lsof`)
  - Review system logs (`journalctl`, `/var/log/`)
  - Track file modifications (`find` with `-mtime`, `stat`)
  - Monitor system calls (`strace`)

- **Rootkit Detection**:
  - `chkrootkit` - Check for rootkits
  - `rkhunter` - Rootkit Hunter
  - Compare system binaries against known good versions
  - Check for kernel module anomalies (`lsmod`)

- **Network Security**:
  - Monitor active connections
  - Analyze packet captures with `tcpdump`
  - Review firewall rules (`iptables`, `ufw`, `firewalld`)
  - Check for suspicious listening ports
  - Analyze DNS queries and responses

### System Hardening
- **File Integrity**:
  - Set up file integrity monitoring (AIDE, Tripwire)
  - Verify checksums and signatures
  - Monitor critical system files
  - Implement proper file permissions

- **Access Control**:
  - Review user accounts and privileges
  - Audit sudo configurations
  - Check SSH configurations
  - Implement principle of least privilege
  - Review PAM configurations

- **Security Updates**:
  - Check for available security patches
  - Verify system is up to date
  - Monitor CVE databases for relevant vulnerabilities

### Log Analysis
- **System Logs**:
  - `/var/log/auth.log` - Authentication attempts
  - `/var/log/syslog` - System messages
  - `/var/log/kern.log` - Kernel messages
  - `/var/log/fail2ban.log` - Failed login attempts
  - `journalctl` - Systemd journal

- **Analysis Techniques**:
  - Identify failed login attempts
  - Detect privilege escalation attempts
  - Find unusual process executions
  - Track file access patterns
  - Correlate events across multiple logs

### Malware Analysis
- **Static Analysis**:
  - Examine file without execution
  - Analyze strings and metadata
  - Review imports and exports
  - Identify packing/obfuscation
  - Extract indicators of compromise (IOCs)

- **Dynamic Analysis** (in isolated environment):
  - Monitor behavior in sandbox
  - Track network communications
  - Observe file system changes
  - Capture system call traces

### Indicators of Compromise
- Unusual outbound network connections
- Unexpected listening ports
- Modified system binaries
- Unknown scheduled tasks or cron jobs
- Suspicious user accounts
- Unusual process names or locations
- High CPU/memory usage from unknown processes
- Gaps in log files
- Modified timestamps on system files

## Common Security Checks

### Quick System Security Audit
```bash
# Check for running unusual processes
ps aux --sort=-%cpu | head -20

# Check network connections
ss -tulpn

# Check for SUID/SGID files
find / -perm /6000 -type f 2>/dev/null

# Check recent authentication attempts
journalctl -u ssh -n 100

# Check for modified system files (requires baseline)
rpm -Va  # RPM-based systems
debsums -c  # Debian-based systems

# Check loaded kernel modules
lsmod

# Check scheduled tasks
crontab -l
ls -la /etc/cron.*
systemctl list-timers

# Check listening ports
netstat -tulpn | grep LISTEN
```

### Ghidra Analysis Workflow
1. Import binary into Ghidra
2. Let auto-analysis complete
3. Review function list for entry points
4. Examine strings for interesting data
5. Analyze control flow graphs
6. Decompile functions of interest
7. Identify vulnerabilities or malicious behavior
8. Document findings

## Resources

The `resources/` directory contains:
- Common IOC lists
- Security audit checklists
- Ghidra script templates
- Log analysis patterns
- Security hardening guides
- Reference materials for common malware families

## Scripts

The `scripts/` directory contains:
- `system-security-check.sh` - Comprehensive system security audit
- `check-intrusion.sh` - Check for signs of intrusion
- `monitor-connections.sh` - Monitor and log network connections
- `analyze-logs.sh` - Parse and analyze security-relevant logs
- `ghidra-batch-analyze.sh` - Batch analysis with Ghidra

## Hooks

The `hooks/` directory contains:
- File integrity monitoring hooks
- Real-time log monitoring hooks
- Network connection alert hooks

## Agents

The `agents/` directory contains:
- `binary-analyzer` - Automated binary analysis
- `log-correlator` - Correlate security events across logs
- `threat-hunter` - Proactive threat hunting
- `incident-responder` - Guide incident response procedures

## Security Tools Reference

### Essential Tools
- **Ghidra** - Reverse engineering
- **Wireshark/tcpdump** - Network analysis
- **AIDE/Tripwire** - File integrity monitoring
- **chkrootkit/rkhunter** - Rootkit detection
- **Lynis** - Security auditing
- **ClamAV** - Antivirus scanning
- **fail2ban** - Intrusion prevention

### Installation Commands
```bash
# Debian/Ubuntu
sudo apt install ghidra wireshark tcpdump aide chkrootkit rkhunter lynis clamav fail2ban

# RHEL/Fedora
sudo dnf install ghidra wireshark tcpdump aide chkrootkit rkhunter lynis clamav fail2ban
```

## Best Practices

1. **Always work in isolated environments** when analyzing potentially malicious files
2. **Document all findings** with timestamps and context
3. **Maintain chain of custody** for forensic evidence
4. **Use read-only mounts** when analyzing compromised systems
5. **Verify tools integrity** before using them
6. **Keep security tools updated**
7. **Follow responsible disclosure** for vulnerabilities
8. **Maintain offline backups** of critical data
9. **Never analyze malware on production systems**
10. **Use VMs or containers** for risky operations

## Integration with Other Skills

- Works with `/red-blue-hat/` for offensive security testing
- Supports `/system-manager/` for security documentation
- Integrates with `/automater/` for automated security monitoring
- Complements `/cleaner/` for secure code practices

## Emergency Response

### If Intrusion Suspected
1. **DO NOT** shut down the system immediately (may lose volatile evidence)
2. Document current system state
3. Capture memory dump if possible
4. Isolate system from network
5. Preserve logs
6. Begin incident response procedures
7. Contact appropriate authorities if required

### Evidence Collection Priority
1. Network connections and processes (most volatile)
2. Memory dump
3. Running processes
4. File system metadata
5. Disk image
6. Log files

## Notes

- Always obtain proper authorization before security testing
- Follow responsible disclosure practices
- Maintain detailed documentation of all security work
- Keep security tools updated
- Use isolated environments for analysis
- Respect privacy and legal boundaries
- Report findings through appropriate channels
