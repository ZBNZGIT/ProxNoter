#!/bin/bash

# Function to clear screen and show header banner consistently
show_header() {
    clear
    echo "=========================================="
    echo "  ProxNoter | https://github.com/ZBNZGIT  "
    echo "=========================================="
}

# Initial clear and banner
show_header

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (or use sudo)"
  exit 1
fi

# 1. Get User Inputs
read -p "Enter VM or LXC ID (e.g., 100): " VMID

# Check if the config file exists and determine type
if [ -f "/etc/pve/qemu-server/${VMID}.conf" ]; then
    CONF_FILE="/etc/pve/qemu-server/${VMID}.conf"
    IS_LXC=false
    DEFAULT_DESC="A virtual machine running on Proxmox VE."
elif [ -f "/etc/pve/lxc/${VMID}.conf" ]; then
    CONF_FILE="/etc/pve/lxc/${VMID}.conf"
    IS_LXC=true
    DEFAULT_DESC="A Linux container running on Proxmox VE."
else
    echo "❌ Error: VM/LXC ID $VMID does not exist on this node."
    exit 1
fi

# Clear for next question
show_header

# FORCE A NAME: Loops indefinitely until the user inputs a name that isn't blank
while true; do
    read -p "Enter VM / LXC Name (e.g., WireGuard): " APP_NAME
    if [ -n "$APP_NAME" ]; then
        break
    else
        show_header
        echo "⚠️ Error: Name cannot be blank. Please try again."
    fi
done

# Clear for next question
show_header
read -p "Enter Description: " APP_DESC

# Clear for next question
show_header
read -p "Enter Port(s) (e.g., 51820/UDP): " APP_PORT
# SANITIZE PORT: Strip all spaces
APP_PORT="${APP_PORT// /}"

# Clear for next question
show_header
read -p "Enter Role (e.g., VPN SERVER): " APP_ROLE

# Clear for next question
show_header
read -p "Enter Icon URL (Copy icon SVG URL from https://selfh.st/icons/): " ICON_URL

# FORCE VALID COLOR OR HEX CODE: Loops until input is valid or left default
while true; do
    show_header
    echo "Choose a badge color (Hex code or name, e.g., Green, Blue, Red):"
    echo "  - 004d00 (Dark Green)"
    echo "  - 3b82f6 (Bright Blue)"
    echo "  - e11d48 (Rose/Red)"
    echo "  - 4b5563 (Sleek Gray)"
    echo "------------------------------------------"
    read -p "Enter color choice [Default: 004d00 (Dark Green)]: " BADGE_COLOR

    # 1. If blank, apply default and break loop
    if [ -z "$BADGE_COLOR" ]; then
        BADGE_COLOR="004d00"
        break
    fi

    # Clean the input slightly for testing (strip spaces and #)
    CLEAN_COLOR="${BADGE_COLOR//#/}"
    CLEAN_COLOR="${CLEAN_COLOR// /}"

    # 2. Check input against accepted styles using Regex:
    #    - 3 or 6 character hex codes (e.g., fff, 004d00)
    #    - Common color names (case-insensitive)
    if [[ "$CLEAN_COLOR" =~ ^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]] || \
       [[ "${CLEAN_COLOR,,}" =~ ^(green|blue|red|gray|grey|black|white|orange|yellow|purple|pink)$ ]]; then
        BADGE_COLOR="$CLEAN_COLOR"
        break
    else
        echo "⚠️ Error: Invalid hex code or color name. Please try again."
        sleep 2
    fi
done

# Clear screen for processing phase
show_header

# Description fallback if left blank
if [ -z "$APP_DESC" ]; then
    APP_DESC="$DEFAULT_DESC"
fi

# Default icon if left blank
if [ -z "$ICON_URL" ]; then
    ICON_URL="https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/proxmox.svg"
fi

# Convert App Name & Role to Uppercase for Header/Badges
APP_NAME_UPPER=$(echo "$APP_NAME" | tr '[:lower:]' '[:upper:]')
APP_ROLE_BADGE=$(echo "$APP_ROLE" | tr '[:lower:]' '[:upper:]' | tr ' ' '_')

# 2. Automatically detect IP Address
echo "Detecting IP address..."
IP_ADDR=""

if [ "$IS_LXC" = true ]; then
    IP_ADDR=$(pct exec $VMID -- ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
else
    IP_ADDR=$(qm guest cmd $VMID network-get-interfaces 2>/dev/null | grep -m 1 -oP '(?<="ip-address" : ")\d+(\.\d+){3}')
fi

if [ -z "$IP_ADDR" ]; then
    echo "⚠️ Warning: Could not automatically detect IP."
    read -p "Please enter the IP manually: " IP_ADDR
    show_header
fi

# SANITIZE IP: Strip all spaces
IP_ADDR="${IP_ADDR// /}"

# URL encode parameters strictly for Shields.io badges (slashes -> %2F)
PORT_ENCODED=$(echo "$APP_PORT" | sed 's/\//%2F/g')
ROLE_ENCODED=$(echo "$APP_ROLE_BADGE" | sed 's/ /_/g')

# 3. Clean up any existing notes/description lines in the configuration file
sed -i '/^description:/d' "$CONF_FILE"
sed -i '/^#/d' "$CONF_FILE" # Clears out old commented notes blocks if any exist

# 4. Inject perfectly formatted multi-line block directly into the configuration file
echo "Injecting notes directly into $CONF_FILE..."

cat << EOF >> "$CONF_FILE"
#<div align="center">
#
## <img src="$ICON_URL" width="80">
## **$APP_NAME_UPPER**
#
#---
#
#**$APP_DESC**
#
#---
#
#![Port](https://img.shields.io/badge/PORT-$PORT_ENCODED-$BADGE_COLOR?style=for-the-badge)
#![IP](https://img.shields.io/badge/IP-$IP_ADDR-$BADGE_COLOR?style=for-the-badge)
#![Role](https://img.shields.io/badge/ROLE-$ROLE_ENCODED-$BADGE_COLOR?style=for-the-badge)
#
#</div>
EOF

echo "------------------------------------------"
echo "✅ Success! Notes added with your custom color choice."
echo "Click off and back onto VM/LXC $VMID to view it!"
echo "------------------------------------------"