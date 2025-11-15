# Red Team / Blue Team Security Testing Expert

Expert in offensive security testing (red team) and defensive security operations (blue team). Specializes in penetration testing, vulnerability assessment, security scanning, and defensive countermeasures. Uses tools like Burp Suite, Nmap, Metasploit, and custom exploitation frameworks.

## When to use this skill

- Conducting authorized penetration testing
- Performing vulnerability assessments
- Running security scans on web applications
- Testing network security
- Exploit development and testing
- Security tool configuration (Burp Suite, Nmap, etc.)
- CTF challenges and security competitions
- Defensive security analysis and hardening
- Training and educational security scenarios

## ⚠️ IMPORTANT AUTHORIZATION NOTICE

**This skill is for AUTHORIZED security testing only:**
- Penetration testing engagements with written permission
- CTF (Capture The Flag) competitions
- Security research on owned systems
- Educational and training environments
- Defensive security operations
- Bug bounty programs with proper authorization

**NEVER use for:**
- Unauthorized access attempts
- Malicious activities
- Systems you don't own or have permission to test
- Violating terms of service
- Any illegal activities

Always obtain explicit written authorization before security testing.

## Core Expertise

### Reconnaissance & Information Gathering

#### Passive Reconnaissance
- OSINT (Open Source Intelligence) gathering
- DNS enumeration (`dig`, `nslookup`, `host`)
- WHOIS lookups
- Subdomain enumeration (`sublist3r`, `amass`)
- Search engine reconnaissance
- Social media intelligence gathering
- Public data leak monitoring

#### Active Reconnaissance
- Port scanning with Nmap
- Service version detection
- OS fingerprinting
- Network mapping
- Banner grabbing
- SSL/TLS analysis

### Network Security Testing

#### Nmap Scanning Techniques
```bash
# Quick scan
nmap -F <target>

# Full port scan
nmap -p- <target>

# Service version detection
nmap -sV <target>

# OS detection
nmap -O <target>

# Script scanning
nmap -sC <target>

# Aggressive scan
nmap -A <target>

# Stealthy scan
nmap -sS -T2 <target>

# UDP scan
nmap -sU <target>

# Save results
nmap -oA output <target>
```

#### Network Tools
- **Wireshark/tcpdump** - Packet capture and analysis
- **Netcat** - Swiss army knife of networking
- **Masscan** - Fast port scanner
- **Zmap** - Internet-wide scanner
- **hping3** - Custom packet crafting

### Web Application Testing

#### Burp Suite Workflow
1. **Configure proxy** (usually 127.0.0.1:8080)
2. **Spider/crawl** the application
3. **Passive scanning** for low-hanging fruit
4. **Active scanning** for vulnerabilities
5. **Manual testing** of interesting endpoints
6. **Intruder attacks** for fuzzing/brute force
7. **Repeater** for request manipulation
8. **Sequencer** for randomness analysis

#### Common Web Vulnerabilities (OWASP Top 10)
- SQL Injection (SQLi)
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Server-Side Request Forgery (SSRF)
- XML External Entity (XXE)
- Insecure Deserialization
- Security Misconfiguration
- Broken Authentication
- Sensitive Data Exposure
- Insufficient Logging & Monitoring

#### Web Testing Tools
- **Burp Suite** - Web application security testing platform
- **OWASP ZAP** - Open-source web app scanner
- **SQLmap** - Automated SQL injection tool
- **Nikto** - Web server scanner
- **Dirb/Dirbuster** - Directory brute forcing
- **ffuf** - Fast web fuzzer
- **curl/wget** - Command-line HTTP clients

### Exploitation & Post-Exploitation

#### Metasploit Framework
```bash
# Start Metasploit
msfconsole

# Search for exploits
search <keyword>

# Use an exploit
use exploit/<path>

# Set options
set RHOST <target>
set LHOST <attacker>
set PAYLOAD <payload>

# Show options
show options

# Run exploit
exploit
```

#### Common Exploit Categories
- Remote Code Execution (RCE)
- Privilege Escalation
- Buffer Overflow
- Path Traversal
- File Upload Vulnerabilities
- Command Injection
- Authentication Bypass

#### Post-Exploitation
- Privilege escalation
- Lateral movement
- Data exfiltration (authorized testing only)
- Persistence mechanisms
- Covering tracks (in test environments)
- Evidence collection

### Password & Credential Testing

#### Password Cracking Tools
- **John the Ripper** - Password cracker
- **Hashcat** - GPU-accelerated password recovery
- **Hydra** - Network login cracker
- **Medusa** - Parallel network login bracker
- **CeWL** - Custom wordlist generator

#### Hash Analysis
```bash
# Identify hash type
hashid <hash>
hash-identifier

# Crack with John
john --wordlist=rockyou.txt hashes.txt

# Crack with Hashcat
hashcat -m <mode> -a 0 hashes.txt wordlist.txt
```

### Wireless Security Testing
- **Aircrack-ng** suite for WiFi testing
- WPA/WPA2 cracking
- Evil twin attacks (authorized testing only)
- Wireless packet capture and analysis
- Bluetooth security testing

### Blue Team / Defensive Operations

#### Threat Detection
- Monitor for scanning activity
- Detect exploitation attempts
- Identify anomalous behavior
- Track failed authentication attempts
- Monitor for data exfiltration

#### Defensive Measures
- Implement network segmentation
- Configure firewalls and IDS/IPS
- Enable logging and monitoring
- Apply security patches promptly
- Implement least privilege access
- Use Web Application Firewalls (WAF)
- Enable rate limiting
- Implement SIEM solutions

#### Incident Response
1. **Preparation** - Have IR plan ready
2. **Identification** - Detect and verify incident
3. **Containment** - Limit damage
4. **Eradication** - Remove threat
5. **Recovery** - Restore operations
6. **Lessons Learned** - Post-incident review

### Security Testing Methodology

#### Standard Penetration Testing Process
1. **Planning & Scoping**
   - Define scope and rules of engagement
   - Get written authorization
   - Identify key assets and objectives

2. **Reconnaissance**
   - Passive information gathering
   - Active scanning and enumeration

3. **Vulnerability Analysis**
   - Identify potential vulnerabilities
   - Prioritize by risk and exploitability

4. **Exploitation**
   - Attempt to exploit vulnerabilities
   - Document successful exploits

5. **Post-Exploitation**
   - Assess impact and access level
   - Test lateral movement capabilities

6. **Reporting**
   - Document all findings
   - Provide remediation recommendations
   - Include proof-of-concept details

## Resources

The `resources/` directory contains:
- Wordlists for password testing
- Common payload templates
- Burp Suite configuration profiles
- Nmap scripts collection
- OWASP testing checklist
- Vulnerability databases
- Reporting templates

## Scripts

The `scripts/` directory contains:
- `quick-recon.sh` - Automated reconnaissance
- `web-scan.sh` - Web application scanning wrapper
- `network-scan.sh` - Network enumeration
- `vulnerability-check.sh` - Common vulnerability checks
- `exploit-search.sh` - Search exploit databases
- `report-generator.sh` - Generate testing reports

## Hooks

The `hooks/` directory contains:
- Pre-test authorization verification
- Test activity logging hooks
- Evidence collection hooks

## Agents

The `agents/` directory contains:
- `recon-automator` - Automated reconnaissance
- `vuln-scanner` - Vulnerability assessment
- `exploit-advisor` - Exploit selection and guidance
- `report-writer` - Security testing report generation

## Essential Tools Installation

### Kali Linux / ParrotOS
Most tools pre-installed

### Debian/Ubuntu
```bash
# Core tools
sudo apt update
sudo apt install nmap wireshark metasploit-framework burpsuite \
    sqlmap nikto dirb hydra john hashcat aircrack-ng \
    netcat-traditional tcpdump net-tools

# Additional tools
sudo apt install gobuster ffuf sublist3r masscan hping3
```

### Using Docker
```bash
# Kali Linux in Docker
docker pull kalilinux/kali-rolling
docker run -it kalilinux/kali-rolling

# Install tools in container
apt update && apt install -y kali-linux-default
```

## Best Practices

### Legal & Ethical
1. **Always get written authorization** before testing
2. **Stay within scope** - only test authorized targets
3. **Follow responsible disclosure** for vulnerabilities found
4. **Maintain confidentiality** of findings
5. **Don't cause damage** - be careful with DoS attacks
6. **Document everything** for reporting
7. **Respect privacy** and data protection laws

### Technical Best Practices
1. Use VPNs or isolated networks for testing
2. Take regular backups before testing
3. Use staging environments when possible
4. Start with passive reconnaissance
5. Gradually increase intrusiveness
6. Rate limit your scans to avoid detection
7. Keep detailed logs of all activities
8. Verify findings before reporting
9. Use multiple tools to confirm vulnerabilities
10. Stay up-to-date with latest exploits and defenses

### Reporting Guidelines
- Executive summary for management
- Technical details for IT teams
- Risk ratings for each finding
- Proof-of-concept screenshots/code
- Remediation recommendations
- Timeline for fixing critical issues
- Retest results after fixes

## Common Attack Vectors

### Web Application
- Input validation failures
- Authentication and session management flaws
- Access control issues
- Security misconfigurations
- Injection vulnerabilities
- Insecure dependencies

### Network
- Unpatched services
- Weak credentials
- Misconfigured firewalls
- Lack of network segmentation
- Unencrypted protocols
- Man-in-the-Middle opportunities

### System
- Privilege escalation vulnerabilities
- Weak file permissions
- Outdated software
- Unnecessary services running
- Poor patch management

## CTF (Capture The Flag) Tips

- Start with easy challenges
- Read challenge descriptions carefully
- Check for hidden information (steganography, metadata)
- Try common vulnerabilities first
- Use online CTF tools and resources
- Collaborate with team members
- Document your methodology
- Learn from writeups after events

## Integration with Other Skills

- Works with `/security/` for defensive operations
- Supports `/system-manager/` for security documentation
- Complements `/python-dev/` for custom tool development
- Integrates with `/automater/` for automated security testing

## Emergency Defense Procedures

### Under Active Attack
1. Isolate affected systems from network
2. Preserve evidence (logs, memory dumps)
3. Activate incident response team
4. Document all observations
5. Follow incident response playbook
6. Notify stakeholders as appropriate
7. Begin containment and eradication
8. Plan recovery and remediation

## Notes

- This skill is for **authorized testing only**
- Always follow rules of engagement
- Maintain ethical standards
- Document authorization before testing begins
- Report findings responsibly
- Continuous learning is essential in this field
- Stay updated on latest vulnerabilities and exploits
- Practice in legal environments (labs, CTFs, bug bounties)
