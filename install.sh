#!/bin/bash
set -e
echo "Installing Techfeeds VPN Pro..."
mkdir -p /opt/techfeeds-vpn-pro
cp -r . /opt/techfeeds-vpn-pro/
chmod +x /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh
ln -sf /opt/techfeeds-vpn-pro/techfeeds-vpn-pro.sh /usr/local/bin/techfeeds-vpn-pro
echo "Installation complete."
