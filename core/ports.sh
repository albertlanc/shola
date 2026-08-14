check_port_conflicts() {
    ss -tuln | grep -q ":$1 " && return 1 || return 0
}
