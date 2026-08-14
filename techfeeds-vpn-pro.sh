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

# CLI Argument Handling
if [ -n "$1" ]; then
    case "$1" in
        status)
            echo "--- Service Status ---"
            systemctl is-active ssh xray dnstt-server fail2ban | awk '{print $1}'
            ;;
        diagnose)
            echo "--- System Diagnostics ---"
            echo "IP: $(curl -s4 ifconfig.me)"
            echo "Disk: $(df -h / | awk '$NF=="/"{printf "%s", $5}')"
            echo "Ports:" && ss -tulpen | grep -E ":(22|80|443|8080|53)"
            ;;
        ports)
            ss -tulpen
            ;;
        users)
            echo "--- SSH Users ---"
            awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd
            ;;
        backup)
            DATE=$(date +"%Y%m%d_%H%M%S")
            tar -czf "/opt/techfeeds-vpn-pro/backups/cli_backup_$DATE.tar.gz" /usr/local/etc/xray /etc/ssh /opt/techfeeds-vpn-pro/users 2>/dev/null
            echo "Backup saved: cli_backup_$DATE.tar.gz"
            ;;
        update)
            apt-get update -y
            ;;
        *)
            echo "Usage: techfeeds-vpn-pro {status|diagnose|ports|users|backup|update}"
            ;;
    esac
    exit 0
fi

# Interactive Main Loop
while true; do
    draw_dashboard
    read -p "Select [0-10]: " choice
    case $choice in
        1) ssh_menu ;;
        2) vless_menu ;;
        3) vmess_menu ;;
        4) trojan_menu ;;
        5) dns_menu ;;
        6) ssl_menu ;;
        7) security_menu ;;
        8) service_menu ;;
        9) monitoring_menu ;;
        10) advanced_menu ;;
        0) clear; exit 0 ;;
        *) echo "Invalid option."; sleep 1 ;;
    esac
done
