#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
RESET="\e[0m"

# Banner
echo -e "${CYAN}"
echo -e "
$$$$$$\\  $$$$$$\\  $$$$$$\\ $$\\   $$\\       $$$$$$$$\\$$$$$$\\$$\\      $$\\   $$$$$$$$\\$$$$$$$$\\$$$$$$$\\  
$$  __$$\\$$  __$$\\$$  __$$\\$$$\\  $$ |      $$  _____\\_$$  _$$ |     $$ |  \\__$$  __$$  _____$$  __$$\\ 
$$ /  $$ $$ /  \\__$$ /  $$ $$$$\\ $$ |      $$ |       $$ | $$ |     $$ |     $$ |  $$ |     $$ |  $$ |
$$$$$$$$ \\$$$$$$\\ $$$$$$$$ $$ $$\\$$ |      $$$$$\\     $$ | $$ |     $$ |     $$ |  $$$$$\\   $$$$$$$  |
$$  __$$ |\\____$$\\$$  __$$ $$ \\$$$$ |      $$  __|    $$ | $$ |     $$ |     $$ |  $$  __|  $$  __$$< 
$$ |  $$ $$\\   $$ $$ |  $$ $$ |\\$$$ |      $$ |       $$ | $$ |     $$ |     $$ |  $$ |     $$ |  $$ |
$$ |  $$ \\$$$$$$  $$ |  $$ $$ | \\$$ |      $$ |     $$$$$$\\$$$$$$$$\\$$$$$$$$\\$$ |  $$$$$$$$\\$$ |  $$ |
\\__|  \\__|\\______/\\__|  \\__\\__|  \\__|      \\__|     \\______\\________\\________\\__|  \\________\\__|  \\__|

                ╔═══════ AsanFillter Tunnel Configuration - Standard Edition ═══════╗
                ║                                                                   ║
                ║  • Telegram: @AsanFillter                                        ║
                ║  • Premium Configuration: @Hamedrn                               ║
                ║                                                                   ║
                ╚═══════════════════════════════════════════════════════════════════╝
"
echo -e "${RESET}"

# Loading Animation
loading() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -ne "${CYAN}Processing...${RESET} "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -ne "\b\b\b\b\b\b${GREEN}Done!${RESET}\n"
}

# Asking for file directory and name
read -p "Enter the directory to save the file: " directory
read -p "Enter the filename (without extension): " filename

# Create file
filepath="$directory/$filename.sh"
touch "$filepath"

# Ask for interface name
read -p "Enter the interface name: " interface

# Replace 'eth0' with user-specified interface and write the script
cat > "$filepath" << EOF
#!/bin/bash

tc qdisc del dev $interface root
ip link set dev $interface txqueuelen 5000
tc qdisc add dev $interface root handle 1: htb default 10
tc class add dev $interface parent 1: classid 1:1 htb rate 100Gbit ceil 100Gbit
tc class add dev $interface parent 1:1 classid 1:10 htb rate 25Gbit ceil 100Gbit
tc class add dev $interface parent 1:1 classid 1:20 htb rate 25Gbit ceil 100Gbit
tc class add dev $interface parent 1:1 classid 1:30 htb rate 25Gbit ceil 100Gbit
tc class add dev $interface parent 1:1 classid 1:40 htb rate 25Gbit ceil 100Gbit
tc qdisc add dev $interface parent 1:10 handle 10: cake bandwidth 100gbit flows unlimited
tc qdisc add dev $interface parent 1:20 handle 20: fq_codel
tc qdisc add dev $interface parent 1:30 handle 30: fq_pie
tc qdisc add dev $interface parent 1:40 handle 40: htb
tc filter add dev $interface protocol all parent 1: prio 1 u32 match u32 0 0 flowid 1:1
EOF

# Make the script executable
chmod +x "$filepath"

# Run the script
(
    sudo bash "$filepath"
) & loading $!

# Additional commands
(
    sudo ip link set $interface mtu 1480 && sudo ip link set $interface txqueuelen 3500

    commands=(
        "rx-checksumming on"
        "tx-checksumming on"
        "scatter-gather on"
        "tcp-segmentation-offload on"
        "generic-segmentation-offload on"
        "generic-receive-offload on"
        "rx-vlan-offload on"
        "tx-tcp-mangleid-segmentation off"
        "tx-nocache-copy off"
        "rx-all off"
        "rx-fcs off"
        "rx-gro-list off"
        "rx-udp-gro-forwarding off"
    )

    for cmd in "${commands[@]}"; do
        sudo ethtool -K $interface $cmd
    done

    echo -e "net.ipv4.tcp_retries2=2\nnet.ipv4.tcp_fastopen=3\nnet.ipv4.tcp_fin_timeout=5\nnet.ipv4.tcp_base_mss=1440\nnet.ipv4.tcp_sack=1\nnet.ipv4.tcp_low_latency=1\nnet.core.netdev_max_backlog=50000\nnet.ipv4.ip_local_port_range='1024 65535'\nnet.ipv4.tcp_dsack=1\nnet.ipv4.tcp_init_cwnd=10\nnet.ipv4.tcp_comp_sack_nr=8\nnet.ipv4.tcp_window_scaling=1\nnet.ipv4.tcp_congestion_control=bbr\nnet.ipv4.ip_default_ttl=64\nnet.ipv6.conf.all.hop_limit=64\nnet.ipv4.tcp_keepalive_time=7200\nnet.ipv4.tcp_max_syn_backlog=2048\nnet.ipv4.tcp_fin_timeout=15\nnet.ipv4.ip_forward=1\nnet.core.rmem_max=16777216\nnet.core.wmem_max=16777216" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    sudo tc qdisc del dev $interface root && ip link set dev $interface txqueuelen 100000 && tc qdisc add dev $interface root handle 1: htb default 10 && tc class add dev $interface parent 1: classid 1:1 htb rate 100Gbit ceil 100Gbit && tc class add dev $interface parent 1:1 classid 1:10 htb rate 100Gbit ceil 100Gbit && tc qdisc add dev $interface parent 1:10 handle 10: cake bandwidth 100gbit && tc filter add dev $interface protocol ip parent 1: prio 1 u32 match ip protocol 0 0 flowid 1:10
) & loading $!

echo -e "${GREEN}All tasks completed successfully!${RESET}"
