dns_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SLOWDNS (DNSTT) MANAGER ────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Install & Configure DNSTT Server                      \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Start/Restart DNSTT                                   \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m View DNSTT Logs                                   \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Transport Manager                           \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-3]: \033[0m"
        read -r dns_opt

        case $dns_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ INSTALLING DNSTT SERVER ────────────────────────────────\033[0m"
                echo "│  Checking Port 53 UDP for conflicts...[span_0](start_span)"[span_0](end_span)
                if ss -uln | grep -q ":53 "; then
                    echo -e "│  \033[1;31mWarning: Port 53 is in use (likely by systemd-resolved).\033[0m[span_1](start_span)"[span_1](end_span)
                    echo "│  You must disable systemd-resolved stub listener first.[span_2](start_span)"[span_2](end_span)
                else
                    echo "│  Downloading DNSTT Server...[span_3](start_span)"[span_3](end_span)
                    wget -qO /usr/local/bin/dnstt-server https://github.com/Techfeeds/dnstt/releases/latest/download/dnstt-server 2>/dev/null[span_4](start_span)[span_4](end_span)
                    chmod +x /usr/local/bin/dnstt-server[span_5](start_span)[span_5](end_span)
                    echo -e "│  \033[0;32mDNSTT Server installed.\033[0m[span_6](start_span)"[span_6](end_span)
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_7](start_span)"[span_7](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ DNSTT SERVICE MANAGEMENT ───────────────────────────────\033[0m"
                systemctl restart dnstt-server 2>/dev/null && echo -e "│  \033[0;32mDNSTT service restarted.\033[0m" || echo -e "│  \033[1;33mSystemd service not configured yet.\033[0m[span_8](start_span)"[span_8](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_9](start_span)"[span_9](end_span)
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ DNSTT LOGS ─────────────────────────────────────────────\033[0m"
                journalctl -u dnstt-server -n 20 --no-pager[span_10](start_span)[span_10](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_11](start_span)"[span_11](end_span)
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_12](start_span)[span_12](end_span)
        esac
    done
}
