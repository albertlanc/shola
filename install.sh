#!/bin/bash
# Techfeeds VPN Pro - Ubuntu 24.04 Master Installer
set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo "================================================================"
echo " Starting Techfeeds VPN Pro Installation..."
echo "================================================================"

echo "[1/4] Installing Core Dependencies..."
apt-get update -y -q
apt-get install -y -q curl jq ufw lsof uuid-runtime cron dropbear net-tools fail2ban tar wget

echo "[2/4] Installing Xray Core..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

echo "[3/4] Preparing Directory Architecture..."
mkdir -p /opt/techfeeds-vpn-pro/{core,modules,config,systemd,templates,logs,backups,users}
cp -r . /opt/techfeeds-vpn-pro/

echo "[4/4] Linking Binaries & Setting Permissions..."
chmod +x /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh
ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro

# Generate Base Xray Config if missing
if [ ! -f "/usr/local/etc/xray/config.json" ]; then
cat << 'JSON' > /usr/local/etc/xray/config.json
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none",
        "fallbacks": [
          { "path": "/vmess", "dest": "@vmess" },
          { "path": "/trojan", "dest": "@trojan" },
          { "path": "/ssh", "dest": "127.0.0.1:22" }
        ]
      },
      "streamSettings": { "network": "tcp", "security": "tls", "tlsSettings": { "certificates": [] } }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
JSON
fi
systemctl restart xray || true

echo "================================================================"
echo " Installation Complete!"
echo " Type 'techfeeds-vpn-pro' to open the panel."
echo " Type 'techfeeds-vpn-pro diagnose' to check system health."
echo "================================================================"
