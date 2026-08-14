#!/bin/bash
source /opt/techfeeds-vpn-pro/core/tui.sh
source /opt/techfeeds-vpn-pro/core/ports.sh
source /opt/techfeeds-vpn-pro/modules/ssh.sh
source /opt/techfeeds-vpn-pro/modules/ssl.sh
source /opt/techfeeds-vpn-pro/modules/security.sh
source /opt/techfeeds-vpn-pro/modules/monitoring.sh
source /opt/techfeeds-vpn-pro/modules/dns.sh

while true; do
    draw_dashboard
    read -p "Select [0-10]: " choice
    case $choice in
        1) ssh_menu ;;
        5) dns_menu ;;
        6) ssl_menu ;;
        7) security_menu ;;
        8)
            clear
            echo "Checking essential VPN ports..."
            check_port_conflicts 22 tcp
            check_port_conflicts 80 tcp
            check_port_conflicts 443 tcp
            check_port_conflicts 8080 tcp
            check_port_conflicts 53 udp
            read -p "Press Enter..."
            ;;
        9) monitoring_menu ;;
        0) clear; exit 0 ;;
        *) echo "Module under construction or invalid."; sleep 1 ;;
    esac
done
