#!/bin/bash
source /opt/techfeeds-vpn-pro/core/tui.sh
source /opt/techfeeds-vpn-pro/core/ports.sh
while true; do
    draw_dashboard
    read -p "Select [0-10]: " choice
    case $choice in
        1) source /opt/techfeeds-vpn-pro/modules/ssh.sh; ssh_menu ;;
        0) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
