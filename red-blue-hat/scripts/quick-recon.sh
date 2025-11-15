#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target> [output-dir]"
    echo "Example: $0 example.com ./recon-results"
    exit 1
fi

TARGET=$1
OUTPUT_DIR=${2:-"recon-$TARGET-$(date +%Y%m%d-%H%M%S)"}

mkdir -p "$OUTPUT_DIR"

echo "=== Quick Reconnaissance for $TARGET ==="
echo "Output directory: $OUTPUT_DIR"
echo ""

# DNS enumeration
echo "[*] DNS enumeration..."
dig "$TARGET" ANY > "$OUTPUT_DIR/dns-any.txt"
nslookup "$TARGET" > "$OUTPUT_DIR/nslookup.txt"
host "$TARGET" > "$OUTPUT_DIR/host.txt"
echo "✓ DNS results saved"

# WHOIS
echo "[*] WHOIS lookup..."
whois "$TARGET" > "$OUTPUT_DIR/whois.txt" 2>&1 || echo "WHOIS lookup failed"
echo "✓ WHOIS saved"

# Port scanning (top 1000 ports)
echo "[*] Port scanning (top 1000 ports)..."
if command -v nmap &> /dev/null; then
    nmap -F -oA "$OUTPUT_DIR/nmap-fast" "$TARGET"
    echo "✓ Fast scan complete"

    # Service version detection on open ports
    echo "[*] Service version detection..."
    nmap -sV -oA "$OUTPUT_DIR/nmap-services" "$TARGET"
    echo "✓ Service scan complete"
else
    echo "! Nmap not installed - skipping port scans"
fi

# HTTP headers
echo "[*] Checking HTTP headers..."
curl -I "http://$TARGET" > "$OUTPUT_DIR/http-headers.txt" 2>&1 || echo "HTTP failed"
curl -I "https://$TARGET" > "$OUTPUT_DIR/https-headers.txt" 2>&1 || echo "HTTPS failed"
echo "✓ HTTP headers saved"

# SSL/TLS information
echo "[*] SSL/TLS certificate information..."
echo | openssl s_client -connect "$TARGET:443" -servername "$TARGET" 2>/dev/null | openssl x509 -text > "$OUTPUT_DIR/ssl-cert.txt" 2>&1 || echo "SSL check failed"
echo "✓ SSL info saved"

echo ""
echo "=== Reconnaissance Complete ==="
echo "Results saved in: $OUTPUT_DIR"
echo ""
echo "Summary:"
grep -h "open" "$OUTPUT_DIR"/nmap*.nmap 2>/dev/null || echo "No Nmap results"
