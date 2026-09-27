hysteria_menu() {
    while true; do
        clear
        local HY2_STAT=$(systemctl is-active --quiet hysteria-server && echo -e "\033[0;32m[ONLINE]\033[0m" || echo -e "\033[0;31m[OFFLINE]\033[0m")
        local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
        local PORT=$(awk '/listen:/ {print $2}' /etc/hysteria/config.yaml 2>/dev/null | grep -o "[0-9]*")
        
        # Enforces Port 53 fallback for your custom configuration
        [ -z "$PORT" ] && PORT="53"
        
        echo -e "\033[0;34m ┌── \033[0;33mHYSTERIA V2 MANAGER\033[0;34m ──────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Service Status : $HY2_STAT                               \033[0;34m│\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Active Port    : \033[1;37m$PORT (UDP)\033[0m                           \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mCONFIGURATION PROFILES \033[0;34m────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Create Hysteria V2 User Account                   \033[0;34m│\033[0m"
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
                echo -e "\033[0;34m ┌── \033[0;33mADD HYSTERIA V2 USER ACCOUNT\033[0;34m ─────────────────────────┐\033[0m"
                read -p " │  1. Username            : " username
                read -p " │  2. Password            : " password
                read -p " │  3. Duration (Days)     : " duration
                read -p " │  4. Max Devices         : " devices
                read -p " │  5. Bandwidth Quota(GB) : " quota
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"

                # Calculate expiration
                exp_date=$(date -d "+$duration days" +"%Y-%m-%d")

                # Add password to Hysteria config and restart
                sed -i "/auth:/a \ \ \ \ - $password" /etc/hysteria/config.yaml 2>/dev/null
                systemctl restart hysteria-server hy2 > /dev/null 2>&1

                # Log tracking details to automated quota database
                mkdir -p /etc/techfeeds
                echo "$username:$password:$exp_date:$devices:$quota" >> /etc/techfeeds/user_quotas.db

                # Generate Payload (Uses password for auth token, username for the remark tag)
                hy2_link="hy2://$password@$DOMAIN:$PORT/?sni=$DOMAIN&insecure=1#$username"

                clear
                echo -e "\033[0;34m======================================================\033[0m"
                echo -e "\033[0;33m      SYSTEM ACCOUNT CREATED (HYSTERIA V2)            \033[0m"
                echo -e "\033[0;34m======================================================\033[0m"
                echo -e " Username      : \033[1;37m$username\033[0m"
                echo -e " Password      : \033[1;37m$password\033[0m"
                echo -e " Expiry Days   : \033[1;37m$duration Days (Expires: $exp_date)\033[0m"
                echo -e " Max Logins    : \033[1;37m$devices Devices\033[0m"
                echo -e " Data Quota    : \033[1;37m$quota GB\033[0m"
                echo -e " Domain/Host   : \033[1;37m$DOMAIN\033[0m"
                echo -e " Active Port   : \033[1;37m$PORT (UDP)\033[0m"
                echo -e "\033[0;34m------------------------------------------------------\033[0m"
                echo -e "\033[0;33m HY2 PAYLOAD   :\033[0m"
                echo -e "\033[36m$hy2_link\033[0m"
                echo -e "\033[0;34m======================================================\033[0m"
                echo ""
                read -p "Press Enter to return to menu..."
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
