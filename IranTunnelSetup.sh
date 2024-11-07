#!/bin/bash

# Clear the screen
clear

# Display banner
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

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initial setup with detailed prompts
echo -e "${BLUE}Please specify the storage path for the files (default: /root/tunnels):${NC}"
read -r storage_path
storage_path=${storage_path:-/root/tunnels}
if [ "$storage_path" == "/root/tunnels" ]; then
    echo -e "${GREEN}Default storage path /root/tunnels in consideration.${NC}"
fi

# Create directory if it doesn't exist
mkdir -p "$storage_path"

# Choose download file
echo -e "\n${BLUE}Which version of the file do you need?${NC}"
echo -e "${GREEN}1) backhaul_linux_amd64.tar.gz${NC}"
echo -e "${GREEN}2) backhaul_linux_arm64.tar.gz${NC}"
read -r file_choice

if [[ $file_choice == "1" ]]; then
    file_name="backhaul_linux_amd64.tar.gz"
elif [[ $file_choice == "2" ]]; then
    file_name="backhaul_linux_arm64.tar.gz"
else
    echo -e "${RED}Invalid choice.${NC}"
    exit 1
fi

# Download file
echo -e "\n${BLUE}Downloading $file_name ...${NC}"
wget -q --show-progress "https://github.com/Musixal/Backhaul/releases/latest/download/$file_name" -P "$storage_path"

# Extract the file
echo -e "${BLUE}Extracting $file_name ...${NC}"
tar -xzf "$storage_path/$file_name" -C "$storage_path"

# Remove extra files and the downloaded archive
rm -f "$storage_path/LICENSE" "$storage_path/README.md" "$storage_path/$file_name"

# Config name with input validation
while true; do
    echo -e "\n${BLUE}Please enter the name of the configuration file (without the .toml extension):${NC}"
    read -r config_name
    if [[ -n $config_name ]]; then
        config_file="$storage_path/$config_name.toml"
        break
    else
        echo -e "${RED}Configuration name cannot be empty. Please enter a valid name.${NC}"
    fi
done

# Choose protocol
while true; do
    echo -e "\n${BLUE}Which protocol would you like to use? Options are: TCP, TCPMUX, or WS.${NC}"
    read -r protocol
    if [[ $protocol == "TCP" || $protocol == "TCPMUX" || $protocol == "WS" ]]; then
        break
    else
        echo -e "${RED}Invalid protocol. Please enter TCP, TCPMUX, or WS.${NC}"
    fi
done

# Write initial config based on the selected protocol
case $protocol in
  "TCP")
    cat <<EOF > "$config_file"
[server]
bind_addr = "0.0.0.0:3080"
transport = "tcp"
accept_udp = false
token = "your_token"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = []
EOF
    ;;
  "TCPMUX")
    cat <<EOF > "$config_file"
[server]
bind_addr = "0.0.0.0:3080"
transport = "tcpmux"
token = "your_token"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768
mux_receivebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = []
EOF
    ;;
  "WS")
    cat <<EOF > "$config_file"
[server]
bind_addr = "0.0.0.0:8080"
transport = "ws"
token = "your_token"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = []
EOF
    ;;
esac

# Detailed prompts for advanced configuration with validation
while true; do
    echo -e "\n${BLUE}Please enter the server IP address to bind to (required):${NC}"
    read -r ip_address
    if [[ -n $ip_address ]]; then
        sed -i "s|bind_addr = \"0.0.0.0|bind_addr = \"$ip_address|" "$config_file"
        break
    else
        echo -e "${RED}IP address cannot be empty.${NC}"
    fi
done

while true; do
    echo -e "\n${BLUE}Please enter the bind port (required):${NC}"
    read -r bind_port
    if [[ -n $bind_port ]]; then
        sed -i "s|bind_addr = \"$ip_address:.*|bind_addr = \"$ip_address:$bind_port\"|" "$config_file"
        break
    else
        echo -e "${RED}Bind port cannot be empty.${NC}"
    fi
done

while true; do
    echo -e "\n${BLUE}Enter the token (password) for authentication (required):${NC}"
    read -r token
    if [[ -n $token ]]; then
        sed -i "s|token = \"your_token\"|token = \"$token\"|" "$config_file"
        break
    else
        echo -e "${RED}Token cannot be empty.${NC}"
    fi
done

echo -e "\n${BLUE}Please enter the keepalive period in seconds (default is 75):${NC}"
read -r keepalive
keepalive=${keepalive:-75}
if [ "$keepalive" == "75" ]; then
    echo -e "${GREEN}Default keepalive period 75 in consideration.${NC}"
fi
sed -i "s|keepalive_period = .*|keepalive_period = $keepalive|" "$config_file"

while true; do
    echo -e "\n${BLUE}Should nodelay be enabled? (true/false)${NC}"
    read -r nodelay
    if [[ $nodelay == "true" || $nodelay == "false" ]]; then
        sed -i "s|nodelay = .*|nodelay = $nodelay|" "$config_file"
        break
    else
        echo -e "${RED}Please enter 'true' or 'false'.${NC}"
    fi
done

echo -e "\n${BLUE}Enter the heartbeat interval in seconds (default is 40):${NC}"
read -r heartbeat
heartbeat=${heartbeat:-40}
if [ "$heartbeat" == "40" ]; then
    echo -e "${GREEN}Default heartbeat interval 40 in consideration.${NC}"
fi
sed -i "s|heartbeat = .*|heartbeat = $heartbeat|" "$config_file"

echo -e "\n${BLUE}Enter the channel size (default is 2048):${NC}"
read -r channel_size
channel_size=${channel_size:-2048}
if [ "$channel_size" == "2048" ]; then
    echo -e "${GREEN}Default channel size 2048 in consideration.${NC}"
fi
sed -i "s|channel_size = .*|channel_size = $channel_size|" "$config_file"

if [[ $protocol == "TCPMUX" ]]; then
    echo -e "\n${BLUE}Enter the number of mux connections (default is 8):${NC}"
    read -r mux_con
    mux_con=${mux_con:-8}
    if [ "$mux_con" == "8" ]; then
        echo -e "${GREEN}Default mux connections 8 in consideration.${NC}"
    fi
    sed -i "s|mux_con = .*|mux_con = $mux_con|" "$config_file"

    echo -e "\n${BLUE}Enter the mux version (default is 1):${NC}"
    read -r mux_version
    mux_version=${mux_version:-1}
    if [ "$mux_version" == "1" ]; then
        echo -e "${GREEN}Default mux version 1 in consideration.${NC}"
    fi
    sed -i "s|mux_version = .*|mux_version = $mux_version|" "$config_file"

    echo -e "\n${BLUE}Enter the mux frame size (default is 32768):${NC}"
    read -r mux_framesize
    mux_framesize=${mux_framesize:-32768}
    if [ "$mux_framesize" == "32768" ]; then
        echo -e "${GREEN}Default mux frame size 32768 in consideration.${NC}"
    fi
    sed -i "s|mux_framesize = .*|mux_framesize = $mux_framesize|" "$config_file"

    echo -e "\n${BLUE}Enter the mux receive buffer size (default is 4194304):${NC}"
    read -r mux_receivebuffer
    mux_receivebuffer=${mux_receivebuffer:-4194304}
    if [ "$mux_receivebuffer" == "4194304" ]; then
        echo -e "${GREEN}Default mux receive buffer size 4194304 in consideration.${NC}"
    fi
    sed -i "s|mux_receivebuffer = .*|mux_receivebuffer = $mux_receivebuffer|" "$config_file"

    echo -e "\n${BLUE}Enter the mux stream buffer size (default is 65536):${NC}"
    read -r mux_streambuffer
    mux_streambuffer=${mux_streambuffer:-65536}
    if [ "$mux_streambuffer" == "65536" ]; then
        echo -e "${GREEN}Default mux stream buffer size 65536 in consideration.${NC}"
    fi
    sed -i "s|mux_streambuffer = .*|mux_streambuffer = $mux_streambuffer|" "$config_file"
fi

while true; do
    echo -e "\n${BLUE}Should the sniffer be enabled? (true/false)${NC}"
    read -r sniffer
    if [[ $sniffer == "true" || $sniffer == "false" ]]; then
        sed -i "s|sniffer = .*|sniffer = $sniffer|" "$config_file"
        break
    else
        echo -e "${RED}Please enter 'true' or 'false'.${NC}"
    fi
done

echo -e "\n${BLUE}Enter the web port (default is 2060):${NC}"
read -r web_port
web_port=${web_port:-2060}
if [ "$web_port" == "2060" ]; then
    echo -e "${GREEN}Default web port 2060 in consideration.${NC}"
fi
sed -i "s|web_port = .*|web_port = $web_port|" "$config_file"

echo -e "\n${BLUE}Enter the path for the traffic log file (default is /root/backhaul.json):${NC}"
read -r sniffer_log
sniffer_log=${sniffer_log:-/root/backhaul.json}
if [ "$sniffer_log" == "/root/backhaul.json" ]; then
    echo -e "${GREEN}Default traffic log path /root/backhaul.json in consideration.${NC}"
fi
sed -i "s|sniffer_log = .*|sniffer_log = \"$sniffer_log\"|" "$config_file"

echo -e "\n${BLUE}Enter the ports (e.g., 3000=3000,4000=4000):${NC}"
read -r ports
ports_array=$(echo "$ports" | sed 's/,/","/g')
sed -i "s|ports = \[\]|ports = [\"$ports_array\"]|" "$config_file"

# Service configuration
echo -e "\n${BLUE}Please enter a name for the service:${NC}"
read -r service_name

service_file="/etc/systemd/system/$service_name.service"

cat <<EOF > "$service_file"
[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=$storage_path/backhaul -c $config_file
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo -e "\n${BLUE}Enabling and starting the service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable "$service_name.service"
sudo systemctl start "$service_name.service"
sudo systemctl restart "$service_name.service"

# Show service status
echo -e "\n${BLUE}Service status:${NC}"
sudo systemctl status "$service_name.service"
