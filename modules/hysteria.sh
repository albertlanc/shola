hysteria_menu() {
    while true; do
        clear
        local HY2_STAT=$(systemctl is-active --quiet hysteria-server && echo -e "\033[0;32m[ONLINE]\033[0m" || echo -e "\033[0;31m[OFFLINE]\033[0m")
        local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
        local PORT=$(awk '/listen:/ {print $2}' /etc/hysteria/config.yaml 2>/dev/null | grep -o "[0-9]*")
        local PASS=$(awk '/password:/ {print $2}' /etc/hysteria/config.yaml 2>/dev/null)
        
        [ -z "$PORT" ] && PORT="443"
        
        echo -e "\033[0;34m ┌── \033[0;33mHYSTERIA V2 MANAGER\033[0;34m ──────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Service Status : $HY2_STAT                               \033[0;34m│\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Active Port    : \033[1;37m$PORT (UDP)\033[0m                           \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mCONFIGURATION PROFILES \033[0;34m────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Generate Hysteria V2 Universal Link               \033[0;34m│\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e ""
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -ne "\n\033[0;32mSelect option [00-01]: \033[0m"
        read -r opt

        case $opt in
            1|01)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mHYSTERIA V2 LINK\033[0;34m ─────────────────────────────────────┐\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Domain       : \033[1;36m$DOMAIN\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Port (UDP)   : \033[1;32m$PORT\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Password     : \033[1;37m$PASS\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mCONFIGURATION LINK (Copy below) \033[0;34m───────────────────────┤\033[0m"
                echo -e "\033[0;34m │  \033[36mhy2://$PASS@$DOMAIN:$PORT/?sni=$DOMAIN#TechFeeds-Hy2\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
