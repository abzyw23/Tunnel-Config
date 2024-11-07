#!/bin/bash

# Clear the screen
clear

# Display Banner
echo -e "\e[92m"
cat << "EOF"
$$$$$$\  $$$$$$\  $$$$$$\ $$\   $$\       $$$$$$$$\$$$$$$\$$\      $$\   $$$$$$$$\$$$$$$$$\$$$$$$$\  
$$  __$$\$$  __$$\$$  __$$\$$$\  $$ |      $$  _____\_$$  _$$ |     $$ |  \__$$  __$$  _____$$  __$$\ 
$$ /  $$ $$ /  \__$$ /  $$ $$$$\ $$ |      $$ |       $$ | $$ |     $$ |     $$ |  $$ |     $$ |  $$ |
$$$$$$$$ \$$$$$$\ $$$$$$$$ $$ $$\$$ |      $$$$$\     $$ | $$ |     $$ |     $$ |  $$$$$\   $$$$$$$  |
$$  __$$ |\____$$\$$  __$$ $$ \$$$$ |      $$  __|    $$ | $$ |     $$ |     $$ |  $$  __|  $$  __$$< 
$$ |  $$ $$\   $$ $$ |  $$ $$ |\$$$ |      $$ |       $$ | $$ |     $$ |     $$ |  $$ |     $$ |  $$ |
$$ |  $$ \$$$$$$  $$ |  $$ $$ | \$$ |      $$ |     $$$$$$\$$$$$$$$\$$$$$$$$\$$ |  $$$$$$$$\$$ |  $$ |
\__|  \__|\______/\__|  \__\__|  \__|      \__|     \______\________\________\__|  \________\__|  \__|

                ╔═══════ AsanFillter Tunnel Configuration - Standard Edition ═══════╗
                ║                                                                   ║
                ║  • Telegram: @AsanFillter                                        ║
                ║  • Premium Configuration: @Hamedrn                               ║
                ║                                                                   ║
                ╚═══════════════════════════════════════════════════════════════════╝
EOF
echo -e "\e[0m"

# Default save directory
echo
read -p "Enter the directory to save files (default: /root/tunnels): " save_dir
save_dir=${save_dir:-/root/tunnels}

# Create directory if it doesn't exist
mkdir -p "$save_dir"

# Choose version
echo
echo -e "\e[93mChoose the version of the backhaul software to download:\e[0m"
echo -e "\e[96m  1) backhaul_linux_amd64.tar.gz\e[0m   - For 64-bit Linux systems (common for most PCs)."
echo -e "\e[96m  2) backhaul_linux_arm64.tar.gz\e[0m   - For ARM-based Linux systems (e.g., Raspberry Pi)."
read -p "Enter your choice (1 or 2): " version_choice

case $version_choice in
    1) version="backhaul_linux_amd64.tar.gz" ;;
    2) version="backhaul_linux_arm64.tar.gz" ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Download the selected version
echo
echo "Downloading $version..."
curl -L -o "$save_dir/$version" "https://github.com/Musixal/Backhaul/releases/latest/download/$version"

# Extract the file
echo
echo "Extracting $version..."
tar -xzf "$save_dir/$version" -C "$save_dir"

# Remove unnecessary files
echo
echo "Cleaning up..."
rm "$save_dir/$version"
rm "$save_dir/README.md" "$save_dir/LICENSE" 2>/dev/null

# Select protocol
echo
echo "Choose the protocol for your tunnel configuration:"
echo -e "\e[92m  1) TCP\e[0m       - Standard TCP protocol for reliable communication."
echo -e "\e[92m  2) TCPMUX\e[0m    - Multiplexed TCP for efficient resource usage."
echo -e "\e[92m  3) WS\e[0m        - WebSocket protocol for web-based communication."
read -p "Enter your choice (1, 2, or 3): " protocol_choice

# Prepare configuration
echo
read -p "Enter a name for the configuration file: " config_name
config_file="$save_dir/${config_name}.toml"

# Function to add a restart cron job
schedule_restart() {
    local service_name=$1
    echo
    read -p "Enter how many hours between service restarts (0 to skip): " restart_hours
    if [[ "$restart_hours" -gt 0 ]]; then
        echo "Adding a cron job to restart the service every $restart_hours hours..."
        (crontab -l 2>/dev/null; echo "0 */$restart_hours * * * systemctl restart $service_name") | crontab -
    fi
}

case $protocol_choice in
    1) # TCP
        echo "[client]" > "$config_file"
        read -p "Enter the server IP: " server_ip
        read -p "Enter the service port (default: 3080): " service_port
        service_port=${service_port:-3080}
        read -p "Enter the token (password): " token
        read -p "Enter connection pool (default: 8): " connection_pool
        connection_pool=${connection_pool:-8}
        read -p "Enable aggressive pool (true/false, default: false): " aggressive_pool
        aggressive_pool=${aggressive_pool:-false}
        read -p "Enter keepalive period (default: 75): " keepalive_period
        keepalive_period=${keepalive_period:-75}
        read -p "Enter dial timeout (default: 10): " dial_timeout
        dial_timeout=${dial_timeout:-10}
        read -p "Enable nodelay (true/false, default: true): " nodelay
        nodelay=${nodelay:-true}
        read -p "Enter retry interval (default: 3): " retry_interval
        retry_interval=${retry_interval:-3}
        read -p "Enable sniffer (true/false, default: false): " sniffer
        sniffer=${sniffer:-false}
        read -p "Enter web port (default: 2060): " web_port
        web_port=${web_port:-2060}
        read -p "Enter sniffer log path (default: $save_dir/backhaul.json): " sniffer_log
        sniffer_log=${sniffer_log:-"$save_dir/backhaul.json"}

        cat << EOF >> "$config_file"
remote_addr = "$server_ip:$service_port"
transport = "tcp"
token = "$token"
connection_pool = $connection_pool
aggressive_pool = $aggressive_pool
keepalive_period = $keepalive_period
dial_timeout = $dial_timeout
nodelay = $nodelay
retry_interval = $retry_interval
sniffer = $sniffer
web_port = $web_port
sniffer_log = "$sniffer_log"
log_level = "info"
EOF
        ;;
    2) # TCPMUX
        echo "[client]" > "$config_file"
        read -p "Enter the server IP: " server_ip
        read -p "Enter the service port (default: 3080): " service_port
        service_port=${service_port:-3080}
        read -p "Enter the token (password): " token
        read -p "Enter connection pool (default: 8): " connection_pool
        connection_pool=${connection_pool:-8}
        read -p "Enable aggressive pool (true/false, default: false): " aggressive_pool
        aggressive_pool=${aggressive_pool:-false}
        read -p "Enter keepalive period (default: 75): " keepalive_period
        keepalive_period=${keepalive_period:-75}
        read -p "Enter dial timeout (default: 10): " dial_timeout
        dial_timeout=${dial_timeout:-10}
        read -p "Enter retry interval (default: 3): " retry_interval
        retry_interval=${retry_interval:-3}
        read -p "Enter mux version (default: 1): " mux_version
        mux_version=${mux_version:-1}
        read -p "Enter mux frame size (default: 32768): " mux_framesize
        mux_framesize=${mux_framesize:-32768}
        read -p "Enter mux receive buffer size (default: 4194304): " mux_recievebuffer
        mux_recievebuffer=${mux_recievebuffer:-4194304}
        read -p "Enter mux stream buffer size (default: 65536): " mux_streambuffer
        mux_streambuffer=${mux_streambuffer:-65536}
        read -p "Enter heartbeat interval (default: 40): " heartbeat
        heartbeat=${heartbeat:-40}
        read -p "Enable sniffer (true/false, default: false): " sniffer
        sniffer=${sniffer:-false}
        read -p "Enter web port (default: 2060): " web_port
        web_port=${web_port:-2060}
        read -p "Enter sniffer log path (default: $save_dir/backhaul.json): " sniffer_log
        sniffer_log=${sniffer_log:-"$save_dir/backhaul.json"}

        cat << EOF >> "$config_file"
remote_addr = "$server_ip:$service_port"
transport = "tcpmux"
token = "$token"
connection_pool = $connection_pool
aggressive_pool = $aggressive_pool
keepalive_period = $keepalive_period
dial_timeout = $dial_timeout
retry_interval = $retry_interval
mux_version = $mux_version
mux_framesize = $mux_framesize
mux_recievebuffer = $mux_recievebuffer
mux_streambuffer = $mux_streambuffer
heartbeat = $heartbeat
sniffer = $sniffer
web_port = $web_port
sniffer_log = "$sniffer_log"
log_level = "info"
EOF
        ;;
    3) # WS
        echo "[client]" > "$config_file"
        read -p "Enter the server IP: " server_ip
        read -p "Enter the service port (default: 8080): " service_port
        service_port=${service_port:-8080}
        read -p "Enter the edge IP (default: 1.1.1.1): " edge_ip
        edge_ip=${edge_ip:-1.1.1.1}
        read -p "Enter the token (password): " token
        read -p "Enter connection pool (default: 8): " connection_pool
        connection_pool=${connection_pool:-8}
        read -p "Enable aggressive pool (true/false, default: false): " aggressive_pool
        aggressive_pool=${aggressive_pool:-false}
        read -p "Enter keepalive period (default: 75): " keepalive_period
        keepalive_period=${keepalive_period:-75}
        read -p "Enter dial timeout (default: 10): " dial_timeout
        dial_timeout=${dial_timeout:-10}
        read -p "Enter retry interval (default: 3): " retry_interval
        retry_interval=${retry_interval:-3}
        read -p "Enable nodelay (true/false, default: true): " nodelay
        nodelay=${nodelay:-true}
        read -p "Enable sniffer (true/false, default: false): " sniffer
        sniffer=${sniffer:-false}
        read -p "Enter web port (default: 2060): " web_port
        web_port=${web_port:-2060}
        read -p "Enter sniffer log path (default: $save_dir/backhaul.json): " sniffer_log
        sniffer_log=${sniffer_log:-"$save_dir/backhaul.json"}

        cat << EOF >> "$config_file"
remote_addr = "$server_ip:$service_port"
edge_ip = "$edge_ip"
transport = "ws"
token = "$token"
connection_pool = $connection_pool
aggressive_pool = $aggressive_pool
keepalive_period = $keepalive_period
dial_timeout = $dial_timeout
retry_interval = $retry_interval
nodelay = $nodelay
sniffer = $sniffer
web_port = $web_port
sniffer_log = "$sniffer_log"
log_level = "info"
EOF
        ;;
    *)
        echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Create service file
echo
read -p "Enter a name for the service: " service_name
service_file="/etc/systemd/system/${service_name}.service"
cat << EOF > "$service_file"
[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=$save_dir/backhaul -c $config_file
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# Schedule restart
schedule_restart "$service_name"

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable "$service_name"
sudo systemctl start "$service_name"

# Restart the service
echo
echo "Restarting the service to apply all configurations..."
sudo systemctl restart "$service_name"

# Display service status
echo
echo "Service status:"
sudo systemctl status "$service_name"
