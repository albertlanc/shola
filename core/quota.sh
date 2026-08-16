#!/bin/bash
# Techfeeds VPN Pro - Data Quota Monitor

QUOTA_DIR="/etc/techfeeds/quota"
[ ! -d "$QUOTA_DIR" ] && exit 0

for limit_file in "$QUOTA_DIR"/*.limit; do
    [ -e "$limit_file" ] || continue
    user=$(basename "$limit_file" .limit)
    limit=$(cat "$limit_file")
    
    # Clean up if user was manually deleted from system
    if ! id "$user" &>/dev/null; then
        rm -f "$QUOTA_DIR/$user."*
        iptables -D OUTPUT -m owner --uid-owner "$user" 2>/dev/null
        continue
    fi

    # Read live bytes from iptables (No Target rule = silent counter)
    current_bytes=$(iptables -L OUTPUT -v -nx | grep -w "owner UID match $user" | awk '{print $2}' | head -n 1)
    [ -z "$current_bytes" ] && current_bytes=0

    last_bytes=$(cat "$QUOTA_DIR/$user.last" 2>/dev/null || echo 0)
    total=$(cat "$QUOTA_DIR/$user.total" 2>/dev/null || echo 0)

    # Protect against counter resets during server reboots
    if [ "$current_bytes" -lt "$last_bytes" ]; then
        diff=$current_bytes
    else
        diff=$((current_bytes - last_bytes))
    fi

    total=$((total + diff))
    
    echo "$current_bytes" > "$QUOTA_DIR/$user.last"
    echo "$total" > "$QUOTA_DIR/$user.total"

    # Enforce limit
    if [ "$total" -ge "$limit" ]; then
        # Lock account & drop active connections
        passwd -l "$user" &>/dev/null
        pkill -u "$user" sshd &>/dev/null
        
        # Rename file so it flags as exceeded and stops checking
        mv "$limit_file" "$QUOTA_DIR/$user.exceeded"
    fi
done
