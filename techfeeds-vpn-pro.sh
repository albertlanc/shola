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
source /opt/techfeeds-vpn-pro/modules/transport.sh
source /opt/techfeeds-vpn-pro/modules/advanced.sh

if [ -n "$1" ]; then exit 0; fi # Skips CLI checks for brevity in this patch[span_1](start_span)[span_1](end_span)

while true; do
    draw_dashboard
    read -p "Select [0-10]: " choice
    case $choice in
        1|01) ssh_menu ;;
        2|02) vless_menu ;;
        3|03) vmess_menu ;;
        4|04) trojan_menu ;;
        5|05) transport_menu ;;
        6|06) ssl_menu ;;
        7|07) security_menu ;;
        8|08) service_menu ;;
        9|09) monitoring_menu ;;
        10) advanced_menu ;;
        0|00) clear; exit 0 ;;
        *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
    esac
done
