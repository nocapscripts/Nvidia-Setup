#!/bin/bash
set -e

echo "🚀 NVIDIA Setup Launcher"

# Ensure required tools
for cmd in curl python3 tar; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "❌ Missing dependency: $cmd"
    exit 1
  }
done

# Create temp workspace
TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

cd "$TMP_DIR"

echo "📥 Downloading Nvidia-Setup from GitHub..."
sudo curl -fsSL https://github.com/nocapscripts/Nvidia-Setup/archive/refs/heads/main.tar.gz \
  | tar xz

cd Nvidia-Setup-main

# Ensure permissions
sudo chmod +x installers/*.sh start.py

echo "🚀 Launchxu Launching setup..."
sudo python3 start.py
