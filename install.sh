#!/bin/bash
set -e
mkdir -p /opt/techfeeds-vpn-pro/{core,modules,config,systemd,templates,logs,backups,users}
cp -r . /opt/techfeeds-vpn-pro/
chmod +x /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh
ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro

# Comprehensive Xray JSON addressing 443(TLS), 80(Non-TLS), 8080(XHTTP)
mkdir -p /usr/local/etc/xray
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
        "fallbacks": [ { "dest": 80 }, { "path": "/ssh", "dest": "127.0.0.1:22" } ]
      },
      "streamSettings": { "network": "tcp", "security": "tls", "tlsSettings": { "certificates": [ { "certificateFile": "/etc/ssl/techfeeds/fullchain.cer", "keyFile": "/etc/ssl/techfeeds/private.key" } ] } }
    },
    {
      "port": 8080,
      "protocol": "vless",
      "settings": { "clients": [], "decryption": "none" },
      "streamSettings": { "network": "xhttp", "security": "none" }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": { "clients": [] },
      "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "path": "/vmess" } }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
JSON

echo "Architecture updated!"
