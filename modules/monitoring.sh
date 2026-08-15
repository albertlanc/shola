monitoring_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ MONITORING & TOOLS ─────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Full System Diagnostic                                \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Network Traffic & Active Connections                 \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Check Service Health                                  \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-3]: \033[0m"
        read -r mon_opt

        case $mon_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ SYSTEM DIAGNOSTICS ─────────────────────────────────────\033[0m"
                echo "│  Running System Diagnostics...[span_0](start_span)"[span_0](end_span)
                echo "│  - IP Route: $(ip route get 8.8.8.8 | awk '{print $7}')[span_1](start_span)"[span_1](end_span)
                echo "│  - DNS Res: $(nslookup google.com >/dev/null 2>&1 && echo 'OK' || echo 'FAIL')[span_2](start_span)"[span_2](end_span)
                echo "│  - Disk Space: $(df -h / | awk '$NF=="/"{printf "%s", $5}')[span_3](start_span)"[span_3](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_4](start_span)"[span_4](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ NETWORK TRAFFIC & CONNECTIONS ──────────────────────────\033[0m"
                ss -tulpen[span_5](start_span)[span_5](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_6](start_span)"[span_6](end_span)
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ SERVICE HEALTH CHECK ───────────────────────────────────\033[0m"
                echo "│  Checking core services...[span_7](start_span)"[span_7](end_span)
                for svc in ssh xray dropbear fail2ban dnstt-server; do[span_8](start_span)[span_8](end_span)
                    if systemctl is-active --quiet $svc; then[span_9](start_span)[span_9](end_span)
                        echo -e "│  $svc: \033[0;32m● ONLINE\033[0m[span_10](start_span)"[span_10](end_span)
                    else
                        echo -e "│  $svc: \033[0;31m● OFFLINE\033[0m[span_11](start_span)"[span_11](end_span)
                    fi
                done
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_12](start_span)"[span_12](end_span)
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_13](start_span)[span_13](end_span)
        esac
    done
}
