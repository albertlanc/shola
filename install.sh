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
echo -e "\033[0;36m┌─ TECHFEEDS VPN PRO - INSTALLING ELITE ARCHITECTURE ──────\033[0m"

echo -e "│  Installing system dependencies and cloning repository..."
apt-get update -y > /dev/null 2>&1
apt-get install -y curl wget jq uuid-runtime ufw fail2ban tar gawk git golang stunnel4 python3 cmake make gcc g++ at iptables unzip zip ca-certificates socat openvpn easy-rsa > /dev/null 2>&1

rm -rf /opt/techfeeds-vpn-pro
git clone https://github.com/albertlanc/shola.git /opt/techfeeds-vpn-pro > /dev/null 2>&1
find /opt/techfeeds-vpn-pro -type f -name "*.sh" -exec sed -i -E 's/\[span_[a-zA-Z0-9_]+\]\((start_span|end_span)\)//g; s/\+\]//g; s/\+\]//g' {} + 2>/dev/null

mkdir -p /opt/techfeeds-vpn-pro/{backups,users}
mkdir -p /etc/techfeeds/quota
mkdir -p /etc/ssl/techfeeds

echo "$DOMAIN" > /etc/techfeeds/domain
echo "$NS" > /etc/techfeeds/ns
hostnamectl set-hostname "$DOMAIN" 2>/dev/null

echo -e "net.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf 2>/dev/null
sysctl -p > /dev/null 2>&1

echo -e "│  Purging default web servers & clearing Ports 80 and 443..."
systemctl stop nginx apache2 2>/dev/null
systemctl disable nginx apache2 2>/dev/null
killall socat apache2 nginx 2>/dev/null
fuser -k 80/tcp 2>/dev/null
fuser -k 443/tcp 2>/dev/null

echo -e "│  Generating Let's Encrypt SSL for $DOMAIN..."
curl -s https://get.acme.sh | sh > /dev/null 2>&1
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt > /dev/null 2>&1
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --keylength ec-256 --force > /dev/null 2>&1
~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc \
    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
    --key-file /etc/ssl/techfeeds/private.key > /dev/null 2>&1

# Universal read permissions for Xray and Stunnel daemons
chmod 755 /etc/ssl/techfeeds 2>/dev/null
chmod 644 /etc/ssl/techfeeds/* 2>/dev/null

echo -e "│  Installing Xray Core (VLESS, VMess, Trojan, Shadowsocks)..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install > /dev/null 2>&1
mkdir -p /usr/local/etc/xray

cat << 'EOF' > /usr/local/etc/xray/config.json
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "tag": "vless-tls", "port": 8443, "protocol": "vless",
      "settings": { "clients": [], "decryption": "none" },
      "streamSettings": { "network": "tcp", "security": "tls", "tlsSettings": { "certificates": [ { "certificateFile": "/etc/ssl/techfeeds/fullchain.cer", "keyFile": "/etc/ssl/techfeeds/private.key" } ] } }
    },
    {
      "tag": "multiplexer-tcp", "port": 80, "protocol": "vless",
      "settings": { "clients": [ { "id": "54a91504-fb4d-49e5-888e-31d88562be5d", "email": "mux-front" } ], "decryption": "none", "fallbacks": [ { "path": "/vless-ws", "dest": 10001 }, { "path": "/vmess-ws", "dest": 10002 }, { "path": "/trojan-ws", "dest": 10003 }, { "path": "/ss-ws", "dest": 10004 }, { "dest": 8080 } ] },
      "streamSettings": { "network": "tcp" }
    },
    { "tag": "vless-ws", "listen": "127.0.0.1", "port": 10001, "protocol": "vless", "settings": { "clients": [], "decryption": "none" }, "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless-ws" } } },
    { "tag": "vmess-ws", "listen": "127.0.0.1", "port": 10002, "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "wsSettings": { "path": "/vmess-ws" } } },
    { "tag": "trojan-ws", "listen": "127.0.0.1", "port": 10003, "protocol": "trojan", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "wsSettings": { "path": "/trojan-ws" } } },
    { "tag": "shadowsocks-tcp", "port": 8388, "protocol": "shadowsocks", "settings": { "method": "aes-256-gcm", "clients": [] }, "streamSettings": { "network": "tcp" } },
    { "tag": "shadowsocks-ws", "listen": "127.0.0.1", "port": 10004, "protocol": "shadowsocks", "settings": { "method": "aes-256-gcm", "clients": [] }, "streamSettings": { "network": "ws", "wsSettings": { "path": "/ss-ws" } } }
  ],
  "outbounds": [ { "protocol": "freedom", "settings": {} } ]
}
EOF

echo -e "│  Installing OpenVPN (TCP/UDP)..."
make-cadir /etc/openvpn/easy-rsa > /dev/null 2>&1
cd /etc/openvpn/easy-rsa
./easyrsa init-pki > /dev/null 2>&1
EASYRSA_BATCH=1 ./easyrsa build-ca nopass > /dev/null 2>&1
EASYRSA_BATCH=1 ./easyrsa build-server-full server nopass > /dev/null 2>&1
EASYRSA_BATCH=1 ./easyrsa gen-dh > /dev/null 2>&1
openvpn --genkey secret /etc/openvpn/tls-crypt.key > /dev/null 2>&1
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/

PLUGIN_PATH=$(find /usr/lib -name "openvpn-plugin-auth-pam.so" | head -n 1)
cat <<EOF > /etc/openvpn/server-tcp.conf
port 1194
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-crypt tls-crypt.key
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-GCM
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
plugin $PLUGIN_PATH login
verify-client-cert none
username-as-common-name
EOF

cp /etc/openvpn/server-tcp.conf /etc/openvpn/server-udp.conf
sed -i 's/proto tcp/proto udp/' /etc/openvpn/server-udp.conf
sed -i 's/server 10.8.0.0/server 10.9.0.0/' /etc/openvpn/server-udp.conf

systemctl enable --now openvpn@server-tcp > /dev/null 2>&1
systemctl enable --now openvpn@server-udp > /dev/null 2>&1

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1
IFACE=$(ip route | awk '/^default/ {print $5}' | head -n 1)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $IFACE -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o $IFACE -j MASQUERADE

echo -e "│  Installing Hysteria V2 (UDP 443)..."
wget -qO /usr/local/bin/hysteria https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 > /dev/null 2>&1
chmod +x /usr/local/bin/hysteria
mkdir -p /etc/hysteria

cat <<EOF > /etc/hysteria/config.yaml
listen: :443
tls:
  cert: /etc/ssl/techfeeds/fullchain.cer
  key: /etc/ssl/techfeeds/private.key
auth:
  type: password
  password: techfeeds_hy2_master
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF

cat <<EOF > /etc/systemd/system/hysteria-server.service
[Unit]
Description=Hysteria V2 Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
WorkingDirectory=/etc/hysteria
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hysteria-server.service > /dev/null 2>&1

echo -e "│  Installing UDP Custom (Port 36712)..."
wget -q https://raw.githubusercontent.com/rudi9999/UDPserver/main/udp-custom -O /usr/local/bin/udp-custom
chmod +x /usr/local/bin/udp-custom
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom Forwarder
After=network.target

[Service]
ExecStart=/usr/local/bin/udp-custom server -exclude 36712 -l :36712
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now udp-custom > /dev/null 2>&1

echo -e "│  Fixing Port 53 & Installing DNSTT Server..."
systemctl stop systemd-resolved 2>/dev/null
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
sed -i 's/DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null
systemctl enable --now systemd-resolved 2>/dev/null

rm -rf /opt/dnstt
git clone https://www.bamsoftware.com/git/dnstt.git /opt/dnstt > /dev/null 2>&1 || git clone https://github.com/aztecrabbit/dnstt.git /opt/dnstt > /dev/null 2>&1
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

echo -e "│  Setting up Smart WebSocket Proxy (Port 80 routing to SSH & Xray)..."
cat << 'EOF' > /usr/local/bin/ws-proxy.py
import socket, threading, select

def proxy(client):
    try:
        initial_data = client.recv(4096)
        if not initial_data: return
        target_port = 22
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.connect(('127.0.0.1', target_port))
        if target_port == 22 and (b"HTTP/1.1" in initial_data or b"Upgrade: websocket" in initial_data):
            client.send(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        else: server.send(initial_data)
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
    except: pass
    finally: client.close()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('127.0.0.1', 8080))
s.listen(200)
while True:
    c, _ = s.accept()
    threading.Thread(target=proxy, args=(c,)).start()
EOF

cat <<EOF > /etc/systemd/system/ws-proxy.service
[Unit]
Description=Smart WebSocket Proxy
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

echo -e "│  Configuring Stunnel SSL (Port 443 routing to Port 80 proxy)..."
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

echo -e "│  Configuring Advanced Firewall Rules..."
ufw allow 22/tcp > /dev/null 2>&1
ufw allow 53/udp > /dev/null 2>&1
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw allow 443/udp > /dev/null 2>&1
ufw allow 1194/tcp > /dev/null 2>&1
ufw allow 1194/udp > /dev/null 2>&1
ufw allow 8388/tcp > /dev/null 2>&1
ufw allow 36712/udp > /dev/null 2>&1
ufw allow 8080/tcp > /dev/null 2>&1
ufw allow 8443/tcp > /dev/null 2>&1

echo -e "│  Finalizing automated quota tracker..."
chmod +x /opt/techfeeds-vpn-pro/*.sh /opt/techfeeds-vpn-pro/core/*.sh /opt/techfeeds-vpn-pro/modules/*.sh 2>/dev/null
(crontab -l 2>/dev/null | grep -v quota.sh; echo "*/2 * * * * /opt/techfeeds-vpn-pro/core/quota.sh > /dev/null 2>&1") | crontab -

if [ -f /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh ]; then
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/menu
    ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro
fi

systemctl restart xray stunnel4 hysteria-server > /dev/null 2>&1
systemctl enable xray > /dev/null 2>&1

echo -e "│  \033[0;32mInstallation completed successfully!\033[0m"
echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
echo -e "Type \033[1;32mmenu\033[0m anywhere to open your dashboard.\n"
