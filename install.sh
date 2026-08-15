#!/bin/bash

# 1. ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31mError: You must run this installer as root.\033[0m"
    exit 1
fi

clear
echo -e "\033[0;36m┌─ TECHFEEDS VPN PRO - INITIAL SETUP ──────────────────────\033[0m"
echo -e "│  Welcome to the automated server installer."
echo -e "│  Please provide your domain and nameserver below."
echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"

# 2. INTERACTIVE PROMPTS
read -p "Enter your Pointed Domain (e.g., vpn.yourdomain.com): " DOMAIN
read -p "Enter your SlowDNS Nameserver (e.g., ns.yourdomain.com): " NS

clear
echo -e "\033[0;36m┌─ TECHFEEDS VPN PRO - INSTALLING ─────────────────────────\033[0m"

# 3. DIRECTORIES & VARIABLES SETUP
echo -e "│  Creating directory structures..."
mkdir -p /opt/techfeeds-vpn-pro/{modules,core,backups,users}
mkdir -p /etc/techfeeds
mkdir -p /etc/ssl/techfeeds

echo "$DOMAIN" > /etc/techfeeds/domain
echo "$NS" > /etc/techfeeds/ns

# 4. SYSTEM DEPENDENCIES (Includes Stunnel & Compilers)
echo -e "│  Updating OS and installing dependencies..."
apt-get update -y > /dev/null 2>&1
apt-get install -y curl wget jq uuid-runtime ufw fail2ban tar gawk git golang stunnel4 dropbear > /dev/null 2>&1

# 5. XRAY CORE INSTALLATION
echo -e "│  Installing Xray Core..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install > /dev/null 2>&1

# 6. SLOWDNS (DNSTT) COMPILATION & SETUP
echo -e "│  Fixing Port 53 & Installing SlowDNS..."
# Free Port 53 from Ubuntu's internal resolver
systemctl stop systemd-resolved 2>/dev/null
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
sed -i 's/DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null
systemctl enable --now systemd-resolved 2>/dev/null

# Compile DNSTT
rm -rf /opt/dnstt
git clone https://www.bamsoftware.com/git/dnstt.git /opt/dnstt > /dev/null 2>&1
cd /opt/dnstt/dnstt-server && go build
mv dnstt-server /usr/local/bin/
cd /etc/techfeeds
/usr/local/bin/dnstt-server -gen pubkey privkey > /dev/null 2>&1
cat /etc/techfeeds/pubkey > /etc/techfeeds/pubkey.txt

# 7. LET'S ENCRYPT SSL GENERATION
echo -e "│  Generating Let's Encrypt SSL for $DOMAIN..."
systemctl stop xray 2>/dev/null
systemctl stop nginx 2>/dev/null
curl -s https://get.acme.sh | sh > /dev/null 2>&1
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --keylength ec-256 > /dev/null 2>&1
~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc \
    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
    --key-file /etc/ssl/techfeeds/private.key > /dev/null 2>&1
chmod 644 /etc/ssl/techfeeds/*

# 8. DASHBOARD LINKING
echo -e "│  Setting up global commands..."
if [ -f /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh ]; then
    chmod +x /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/menu
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro
fi

# 9. STARTUP SERVICES
systemctl start xray 2>/dev/null

echo -e "│  \033[0;32mInstallation completed successfully!\033[0m"
echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
echo -e "Type \033[1;32mmenu\033[0m anywhere to open your dashboard.\n"
