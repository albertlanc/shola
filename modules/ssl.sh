ssl_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SSL/TLS & DOMAIN MANAGER ───────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Install acme.sh                                       \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Issue & Apply Uniform SSL (Xray, SSH, Dropbear)       \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-2]: \033[0m"
        read -r ssl_opt

        case $ssl_opt in
            1) 
                clear
                echo -e "\033[0;36m┌─ INSTALLING ACME.SH ─────────────────────────────────────\033[0m"
                curl https://get.acme.sh | sh[span_25](start_span)[span_25](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_26](start_span)"[span_26](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ UNIFORM SSL ISSUANCE ───────────────────────────────────\033[0m"
                read -p "│  Enter your domain (e.g., vpn.yourdomain.com): " domain[span_27](start_span)[span_27](end_span)
                systemctl stop xray 2>/dev/null[span_28](start_span)[span_28](end_span)
                ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --keylength ec-256[span_29](start_span)[span_29](end_span)
                mkdir -p /etc/ssl/techfeeds
                ~/.acme.sh/acme.sh --install-cert -d "$domain" --ecc \
                    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
                    --key-file /etc/ssl/techfeeds/private.key \
                    --reloadcmd "systemctl restart xray ssh dropbear stunnel4 2>/dev/null[span_30](start_span)"[span_30](end_span)
                echo -e "│  \033[0;32mCertificate applied uniformly across all server protocols.\033[0m[span_31](start_span)"[span_31](end_span)
                systemctl start xray 2>/dev/null[span_32](start_span)[span_32](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_33](start_span)"[span_33](end_span)
                ;;
            0) return ;;
        esac
    done
}
