# NVIDIA Linux Driver Installer 🚀

A simple, universal script to install NVIDIA drivers on **any Linux distribution**, supporting **older Pascal GPUs** and the **latest models**. Designed for both new and experienced Linux users.

---

## Features

- ✅ Auto-detect your Linux distribution (Ubuntu/Debian, Fedora, Arch, and more)
- ✅ Supports NVIDIA GPUs from Pascal (GTX 10xx series) to the latest Ampere and Ada Lovelace cards
- ✅ Automatic driver installation with recommended settings
- ✅ Manual installation option for advanced users
- ✅ System update and dependency checks before installation
- ✅ Safe temporary workspace for downloads and execution
- ✅ Interactive menu for easy selection

---

## Supported Distributions

| Distribution | Supported Package Manager |
| ------------ | ------------------------ |
| Ubuntu / Debian | `apt` |
| Fedora | `dnf` |
| Arch / Manjaro | `pacman` | `yay` |
| Other | Manual installation supported |

> Note: For unsupported distributions, the script allows **manual driver installation**.

---

## Quick Start

### 1. Using the Shell Launcher (Recommended)

```bash
# Download and run the launcher
curl -fsSL https://raw.githubusercontent.com/nocapscripts/Nvidia-Setup/main/web-run.sh | bash

```
### 1. Using the Shell Launcher as clone (Recommended)

```bash
# Download and run the launcher
git clone https://github.com/nocapscripts/Nvidia-Setup.git

