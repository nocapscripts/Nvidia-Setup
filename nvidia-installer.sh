#!/bin/bash

LOG="/var/log/nvidia-auto-installer.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== NVIDIA AUTO INSTALLER STARTED ==="

# Root check
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root"
  exit 1
fi

set -euo pipefail

# Detect real user
REAL_USER=${SUDO_USER:-root}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Create nvidia-driver folder
DRIVER_DIR="$USER_HOME/nvidia-driver"
mkdir -p "$DRIVER_DIR"

# Architecture check
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "❌ Unsupported architecture: $ARCH"
  exit 1
fi

# NVIDIA GPU check
echo "🔍 Detecting NVIDIA GPU..."
if ! lspci | grep -qi nvidia; then
  echo "❌ No NVIDIA GPU detected"
  exit 1
fi

# Dependencies
echo "📦 Installing dependencies..."
apt update
apt install -y build-essential dkms curl wget pciutils linux-headers-$(uname -r) || true

# Disable Nouveau
echo "🚫 Disabling Nouveau..."
cat > /etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
options nouveau modeset=0
EOF
update-initramfs -u

# Detect active display manager
DM=""
for d in gdm gdm3 sddm lightdm lxdm; do
  if systemctl is-active --quiet "$d"; then
    DM=$d
    break
  fi
done

if [[ -n "$DM" ]]; then
  echo "🛑 Stopping display manager $DM..."
  systemctl stop "$DM"
  sleep 2
fi

# Unload NVIDIA modules if loaded
echo "🛠 Unloading any loaded NVIDIA modules..."
for mod in nvidia_drm nvidia_modeset nvidia_uvm nvidia; do
  if lsmod | grep -q "^$mod"; then
    echo "⏹ Removing $mod module..."
    sudo rmmod "$mod" || echo "⚠️ Could not remove $mod (may still be in use)"
  fi
done

# Fetch latest NVIDIA driver version
echo "🌐 Fetching latest NVIDIA driver version..."
RAW_LINE=$(curl -fsSL https://download.nvidia.com/XFree86/Linux-x86_64/latest.txt | head -n1)
DRIVER_VERSION=$(echo "$RAW_LINE" | awk '{print $1}' | tr -d '[:space:]')
echo "✅ Latest NVIDIA driver: $DRIVER_VERSION"

# Build URL and local file path
DRIVER_URL="https://download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run"
DRIVER_FILE="$DRIVER_DIR/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run"

# Check if driver file exists
if [[ -f "$DRIVER_FILE" ]]; then
  echo "ℹ️ Driver already exists in $DRIVER_DIR, using existing file."
else
  echo "⬇️ Downloading NVIDIA driver to $DRIVER_DIR..."
  wget --progress=bar:force --tries=5 --timeout=30 -O "$DRIVER_FILE" "$DRIVER_URL"
  if [[ ! -s "$DRIVER_FILE" ]]; then
    echo "❌ Driver download failed"
    [[ -n "$DM" ]] && systemctl start "$DM"
    exit 1
  fi
fi

chmod +x "$DRIVER_FILE"
chown "$REAL_USER":"$REAL_USER" "$DRIVER_FILE"

# Install driver
echo "🚀 Installing NVIDIA driver..."
"$DRIVER_FILE" --silent --dkms --disable-nouveau --no-backup --no-cc-version-check

echo "✅ NVIDIA driver installed successfully"
echo "📄 Log saved to $LOG"
echo "📁 Driver file: $DRIVER_FILE"

# Restart display manager if it was stopped
if [[ -n "$DM" ]]; then
  echo "🔁 Restarting display manager $DM..."
  systemctl start "$DM"
fi

# Reboot prompt
read -rp "🔁 Reboot now to fully activate driver? [Y/n]: " r
r=${r:-Y}
[[ "$r" =~ ^[Yy]$ ]] && reboot || echo "⚠️ Reboot required to fully activate NVIDIA driver"
