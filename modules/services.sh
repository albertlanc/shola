service_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SERVICE & PORT MANAGER ─────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m List All Listening Ports (ss)                         \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Restart Core Services (SSH, Xray, DNSTT)              \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Stop a Service                                        \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m View Service Logs (journalctl)                        \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-4]: \033[0m"
        read -r srv_opt

        case $srv_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ LISTENING PORTS ────────────────────────────────────────\033[0m"
                ss -tulpen[span_60](start_span)[span_60](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_61](start_span)"[span_61](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ RESTART SERVICES ───────────────────────────────────────\033[0m"
                echo "│  Restarting services...[span_62](start_span)"[span_62](end_span)
                systemctl restart ssh xray dnstt-server 2>/dev/null[span_63](start_span)[span_63](end_span)
                echo -e "│  \033[0;32m● Services restarted.\033[0m[span_64](start_span)"[span_64](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_65](start_span)"[span_65](end_span)
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ STOP SERVICE ───────────────────────────────────────────\033[0m"
                read -p "│  Enter service name to stop (e.g., xray): " svc_name[span_66](start_span)[span_66](end_span)
                systemctl stop "$svc_name[span_67](start_span)"[span_67](end_span)
                echo -e "│  \033[0;32m$svc_name stopped.\033[0m[span_68](start_span)"[span_68](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_69](start_span)"[span_69](end_span)
                ;;
            4)
                clear
                echo -e "\033[0;36m┌─ VIEW SERVICE LOGS ──────────────────────────────────────\033[0m"
                read -p "│  Enter service name to view logs (e.g., dnstt-server): " svc_name[span_70](start_span)[span_70](end_span)
                journalctl -u "$svc_name" -n 50 --no-pager[span_71](start_span)[span_71](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_72](start_span)"[span_72](end_span)
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_73](start_span)[span_73](end_span)
        esac
    done
}
