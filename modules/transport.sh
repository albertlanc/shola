transport_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ XRAY & TRANSPORT MANAGER ───────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Check Xray Status                                   \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m View Xray Logs                                      \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Restart Xray Core                                   \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m Validate Xray Configuration Syntax                    \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[5]\033[0;36m SlowDNS (DNSTT) Manager                             \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-5]: \033[0m"
        read -r t_opt

        case $t_opt in
            1) clear; echo -e "\033[0;36m┌─ XRAY STATUS ────────────────────────────────────────────\033[0m"; systemctl is-active --quiet xray && echo -e "│  \033[0;32m● Xray is ONLINE\033[0m" || echo -e "│  \033[0;31m● Xray is OFFLINE\033[0m"; echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"; read -p "Press Enter to return...[span_34](start_span)"[span_34](end_span) ;;
            2) clear; echo -e "\033[0;36m┌─ XRAY LOGS ──────────────────────────────────────────────\033[0m"; journalctl -u xray -n 50 --no-pager; echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"; read -p "Press Enter to return...[span_35](start_span)"[span_35](end_span) ;;
            3) clear; echo -e "\033[0;36m┌─ RESTART XRAY ───────────────────────────────────────────\033[0m"; systemctl restart xray && echo -e "│  \033[0;32mXray restarted successfully.\033[0m"; echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"; read -p "Press Enter to return...[span_36](start_span)"[span_36](end_span) ;;
            4) clear; echo -e "\033[0;36m┌─ VALIDATE CONFIG ────────────────────────────────────────\033[0m"; /usr/local/bin/xray -test -config /usr/local/etc/xray/config.json; echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"; read -p "Press Enter to return...[span_37](start_span)"[span_37](end_span) ;;
            5) dns_menu ;;[span_38](start_span)[span_38](end_span)
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_39](start_span)[span_39](end_span)
        esac
    done
}
