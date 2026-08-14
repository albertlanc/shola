#!/bin/bash
source /opt/techfeeds-vpn-pro/core/tui.sh
source /opt/techfeeds-vpn-pro/core/ports.sh
source /opt/techfeeds-vpn-pro/modules/ssh.sh
source /opt/techfeeds-vpn-pro/modules/xray.sh
source /opt/techfeeds-vpn-pro/modules/ssl.sh
source /opt/techfeeds-vpn-pro/modules/security.sh
source /opt/techfeeds-vpn-pro/modules/services.sh
source /opt/techfeeds-vpn-pro/modules/monitoring.sh
source /opt/techfeeds-vpn-pro/modules/dns.sh
source /opt/techfeeds-vpn-pro/modules/advanced.sh

while true; do
    draw_dashboard
    read -p "Select [0-10]: " choice
    case $choice in
        1) ssh_menu ;;
        2) vless_menu ;;
        3) vmess_menu ;;
        4) trojan_menu ;;
        5) dns_menu ;; # Xray transport & DNS multiplexing
        6) ssl_menu ;;
        7) security_menu ;;
        8) service_menu ;;
        9) monitoring_menu ;;
        10) advanced_menu ;;
        0) clear; exit 0 ;;
        *) echo "Invalid option."; sleep 1 ;;
    esac
done
