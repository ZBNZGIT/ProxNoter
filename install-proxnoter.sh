#!/bin/bash

# Ensure the installer is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this installer as root (or use sudo)."
  exit 1
fi

echo "=========================================="
echo "  Installing ProxNoter...                 "
echo "=========================================="

# 1. Download the main script directly from GitHub (Case-Sensitive Link Fixed)
echo "📥 Downloading main script..."
curl -sSL "https://raw.githubusercontent.com/ZBNZGIT/ProxNoter/main/ProxNoter.sh" -o /usr/local/bin/proxnoter

# Check if download succeeded
if [ $? -ne 0 ] || [ ! -f /usr/local/bin/proxnoter ]; then
    echo "❌ Error: Failed to download the script from GitHub."
    exit 1
fi

# 2. Make it executable
echo "⚙️ Setting permissions..."
chmod +x /usr/local/bin/proxnoter

# 3. Add to system-wide bash environment for the root user
BASHRC_FILE="/root/.bashrc"

echo "✏️ Configuring bash environment..."
if [ -f "$BASHRC_FILE" ]; then
    # Check if the alias already exists to avoid duplicate strings on rerun
    if ! grep -q "alias proxnoter=" "$BASHRC_FILE"; then
        echo "" >> "$BASHRC_FILE"
        echo "# ProxNoter Shortcut" >> "$BASHRC_FILE"
        echo "alias proxnoter='/usr/local/bin/proxnoter'" >> "$BASHRC_FILE"
        echo "✅ Added alias 'proxnoter' to $BASHRC_FILE"
    else
        echo "ℹ️ Alias 'proxnoter' already exists in $BASHRC_FILE"
    fi
else
    echo "⚠️ Warning: $BASHRC_FILE not found. You can still run the tool directly typing: proxnoter"
fi

echo "------------------------------------------"
echo "🎉 ProxNoter installation complete!"
echo "Run 'source ~/.bashrc' or restart your terminal."
echo "Then simply type: proxnoter"
echo "------------------------------------------"