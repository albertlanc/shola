#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31mError: You must run this installer as root.\033[0m"
    exit 1
fi

clear
echo -e "\033[0;36m┌─ TECHFEEDS VPN PRO - INITIAL SETUP ──────────────────────\033[0m"
echo -e "│  Welcome to the automated server installer."
echo -e "│  Please provide your domain and nameserver below."
echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"

echo -ne "\033[1;32mEnter your Pointed Domain (e.g., vpn.yourdomain.com): \033[0m"
read DOMAIN
echo -ne "\033[1;32mEnter your SlowDNS Nameserver (e.g., ns.yourdomain.com): \033[0m"
read NS

clear
echo -e "\033[0;36m┌─ TECHFEEDS VPN PRO - INSTALLING ─────────────────────────\033[0m"

echo -e "│  Installing system dependencies and cloning repository..."
apt-get update -y > /dev/null 2>&1
apt-get install -y curl wget jq uuid-runtime ufw fail2ban tar gawk git golang stunnel4 python3 at > /dev/null 2>&1

rm -rf /opt/techfeeds-vpn-pro
git clone https://github.com/albertlanc/shola.git /opt/techfeeds-vpn-pro > /dev/null 2>&1

# AUTO-SANITATION: Automatically purge any stray formatting tags on fresh clone
find /opt/techfeeds-vpn-pro -type f -name "*.sh" -exec sed -i -E 's/\[span_[a-zA-Z0-9_]+\]\((start_span|end_span)\)//g; s/\+\]//g; s/\+\]//g' {} + 2>/dev/null

mkdir -p /opt/techfeeds-vpn-pro/{backups,users}
mkdir -p /etc/techfeeds
mkdir -p /etc/ssl/techfeeds

echo "$DOMAIN" > /etc/techfeeds/domain
echo "$NS" > /etc/techfeeds/ns

hostnamectl set-hostname "$DOMAIN" 2>/dev/null

# SPEED: Enable Google TCP BBR congestion control permanently
echo -e "net.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf 2>/dev/null
sysctl -p > /dev/null 2>&1

echo -e "│  Installing Xray Core..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install > /dev/null 2>&1

echo -e "│  Configuring Multi-Protocol Xray (TLS, Non-TLS, & WebSockets)..."
cat << 'EOF' > /usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "vless-tls",
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/ssl/techfeeds/fullchain.cer",
              "keyFile": "/etc/ssl/techfeeds/private.key"
            }
          ]
        }
      }
    },
    {
      "tag": "vless-ws",
      "port": 8080,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless-ws"
        }
      }
    },
    {
      "tag": "vmess-ws",
      "port": 8080,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess-ws"
        }
      }
    },
    {
      "tag": "trojan-ws",
      "port": 8080,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan-ws"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

echo -e "│  Fixing Port 53 & Installing DNSTT Server..."
systemctl stop systemd-resolved 2>/dev/null
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
sed -i 's/DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null
systemctl enable --now systemd-resolved 2>/dev/null

rm -rf /opt/dnstt
git clone https://www.bamsoftware.com/git/dnstt.git /opt/dnstt > /dev/null 2>&1
cd /opt/dnstt/dnstt-server && go build
mv dnstt-server /usr/local/bin/

cd /etc/techfeeds
/usr/local/bin/dnstt-server -gen-key -privkey-file /etc/techfeeds/privkey -pubkey-file /etc/techfeeds/pubkey
cat /etc/techfeeds/pubkey > /etc/techfeeds/pubkey.txt

cat <<EOF > /etc/systemd/system/dnstt-server.service
[Unit]
Description=DNSTT Server
After=network.target

[Service]
ExecStart=/usr/local/bin/dnstt-server -udp :53 -privkey-file /etc/techfeeds/privkey $NS 127.0.0.1:22
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable dnstt-server > /dev/null 2>&1
systemctl start dnstt-server

echo -e "│  Generating Let's Encrypt SSL for $DOMAIN..."
systemctl stop xray 2>/dev/null
systemctl stop nginx 2>/dev/null
curl -s https://get.acme.sh | sh > /dev/null 2>&1

~/.acme.sh/acme.sh --set-default-ca --server letsencrypt > /dev/null 2>&1
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --keylength ec-256 > /dev/null 2>&1
~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc \
    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
    --key-file /etc/ssl/techfeeds/private.key > /dev/null 2>&1

chmod 644 /etc/ssl/techfeeds/* 2>/dev/null

echo -e "│  Setting up Smart WebSocket Proxy (Port 80 routing to SSH & Xray)..."
cat << 'EOF' > /usr/local/bin/ws-proxy.py
import socket, threading, select

def proxy(client):
    try:
        initial_data = client.recv(4096)
        if not initial_data:
            client.close()
            return
            
        target_port = 22 # Default to SSH
        
        # Check if the request is targeting Xray WebSockets
        if b"/vless-ws" in initial_data or b"/vmess-ws" in initial_data or b"/trojan-ws" in initial_data:
            target_port = 8080 # Route to Xray non-TLS inbound

        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.connect(('127.0.0.1', target_port))
        
        # If it's SSH websocket, respond with switching protocols handshake
        if target_port == 22 and b"HTTP/1.1" in initial_data:
            client.send(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        else:
            server.send(initial_data)

        while True:
            r, _, _ = select.select([client, server], [], [])
            if client in r:
                data = client.recv(4096)
                if not data: break
                server.send(data)
            if server in r:
                data = server.recv(4096)
                if not data: break
                client.send(data)
    except:
        pass
    finally:
        client.close()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 80))
s.listen(200)
while True:
    c, _ = s.accept()
    threading.Thread(target=proxy, args=(c,)).start()
EOF

cat <<EOF > /etc/systemd/system/ws-proxy.service
[Unit]
Description=Smart WebSocket Proxy for SSH and Xray
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/ws-proxy.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ws-proxy > /dev/null 2>&1

echo -e "│  Configuring Stunnel SSL (Port 443)..."
cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = /etc/ssl/techfeeds/fullchain.cer
key = /etc/ssl/techfeeds/private.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh-ws-ssl]
accept = 443
connect = 127.0.0.1:80
EOF

sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl enable --now stunnel4 > /dev/null 2>&1

echo -e "│  Configuring Firewall Rules..."
ufw allow 22/tcp > /dev/null 2>&1
ufw allow 53/udp > /dev/null 2>&1
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw allow 8080/tcp > /dev/null 2>&1
ufw allow 8443/tcp > /dev/null 2>&1

echo -e "│  Setting up global commands..."
chmod +x /opt/techfeeds-vpn-pro/*.sh /opt/techfeeds-vpn-pro/core/*.sh /opt/techfeeds-vpn-pro/modules/*.sh 2>/dev/null

if [ -f /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh ]; then
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/menu
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro
fi

systemctl restart xray > /dev/null 2>&1
systemctl enable xray > /dev/null 2>&1

echo -e "│  \033[0;32mInstallation completed successfully!\033[0m"
echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
echo -e "Type \033[1;32mmenu\033[0m anywhere to open your dashboard.\n"
