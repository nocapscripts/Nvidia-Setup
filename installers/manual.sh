#!/bin/bash
set -e

# ================= COLORS =================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RESET="\033[0m"
BOLD="\033[1m"

info()    { echo -e "${BLUE}➜ $1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}✅ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error()   { echo -e "${RED}${BOLD}❌ $1${RESET}"; exit 1; }

# ================= GPU CHECK =================
info "Detecting NVIDIA GPU..."
if ! command -v lspci >/dev/null || ! lspci | grep -i nvidia >/dev/null; then
  error "No NVIDIA GPU detected"
fi
lspci | grep -i nvidia

# ================= DISTRO DETECTION =================
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  error "Cannot detect Linux distribution"
fi

DISTRO="$ID"
info "Detected distro: $DISTRO"

# ================= DRIVER SELECTION =================
echo
echo -e "${CYAN}${BOLD}Select NVIDIA driver branch:${RESET}"
echo "1) Stable (recommended)"
echo "2) Experimental 580 (AUR / beta)"
echo "3) Experimental 590 (AUR / beta)"
echo "4) Legacy 470 (Pascal-safe)"
echo "5) Cancel"
echo

read -rp "Choice: " CHOICE

case "$CHOICE" in
  1) DRIVER="stable" ;;
  2) DRIVER="580" ;;
  3) DRIVER="590" ;;
  4) DRIVER="470" ;;
  *) error "Cancelled by user" ;;
esac

# ================= INSTALL PER DISTRO =================
case "$DISTRO" in

# -------- ARCH BASED --------
arch|manjaro|endeavouros)
  command -v yay >/dev/null || error "yay is required on Arch-based distros"

  if [[ "$DRIVER" == "590" ]]; then
    warn "Installing EXPERIMENTAL NVIDIA $DRIVER drivers via AUR"
    yay -S --needed --noconfirm linux-headers dkms
    yay -S --noconfirm nvidia-dkms nvidia-utils nvidia-settings
  elif [[ "$DRIVER" == "470" ]]; then
    yay -S --noconfirm nvidia-470xx-dkms nvidia-470xx-utils nvidia-470xx-settings
  elif [[ "$DRIVER" == "580" ]]; then
        yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils nvidia-580xx-settings
  else
    yay -S --noconfirm nvidia nvidia-utils nvidia-settings
  fi
  ;;

# -------- DEBIAN / UBUNTU --------
ubuntu|debian|linuxmint|pop)
  sudo apt update
  sudo apt install -y dkms build-essential linux-headers-$(uname -r)

  if [[ "$DRIVER" == "470" ]]; then
    sudo apt install -y nvidia-driver-470
  else
    sudo apt install -y nvidia-driver
  fi
  ;;

# -------- FEDORA / RHEL --------
fedora|rhel|rocky|almalinux|centos)
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
  ;;

# -------- OPENSUSE --------
opensuse*|suse)
  sudo zypper install -y nvidia-glG06 nvidia-video-G06
  ;;

# -------- GENTOO --------
gentoo)
  sudo emerge --ask nvidia-drivers
  ;;

# -------- VOID --------
void)
  sudo xbps-install -Sy nvidia
  ;;

# -------- ALPINE --------
alpine)
  sudo apk add nvidia nvidia-utils
  ;;

# -------- FALLBACK --------
*)
  error "Unsupported or unknown distro: $DISTRO"
  ;;
esac

# ================= POST INSTALL =================
info "Enabling NVIDIA DRM modeset"
sudo bash -c 'echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf'

success "NVIDIA driver installation completed"
echo -e "${YELLOW}${BOLD}🔁 Reboot required to load NVIDIA drivers${RESET}"
