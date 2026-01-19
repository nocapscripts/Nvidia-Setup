#!/usr/bin/env python3

import subprocess
import sys
import os

# ========= COLORS =========
RESET = "\033[0m"
BOLD = "\033[1m"

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
CYAN = "\033[36m"
MAGENTA = "\033[35m"

# ========= UTILS =========
def run_command(cmd, sudo=False):
    if sudo:
        cmd = ["sudo"] + cmd
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError:
        print(f"{RED}{BOLD}❌ Command failed:{RESET} {' '.join(cmd)}")
        sys.exit(1)

def banner():
    os.system("clear")
    print(f"""{CYAN}{BOLD}
========================================
   🚀 SYSTEM SETUP WIZARD
========================================
{RESET}""")

def print_menu():
    print(f"{YELLOW}{BOLD}Choose an option:{RESET}\n")
    print(f"{GREEN}1){RESET} Install NVIDIA Drivers (Auto Detect)")
    print(f"{GREEN}2){RESET} Install NVIDIA Drivers (Manual)")
    print(f"{GREEN}3){RESET} Update System")
    print(f"{GREEN}4){RESET} Install All")
    print(f"{RED}5){RESET} Exit\n")

def pause():
    input(f"{MAGENTA}Press Enter to continue...{RESET}")

# ========= MAIN =========
def main():
    # Ensure script runs from project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    while True:
        banner()
        print_menu()
        choice = input(f"{CYAN}➜ Select an option:{RESET} ").strip()

        if choice == "1":
            print(f"\n{BLUE}🔍 Auto-detecting and installing NVIDIA drivers...{RESET}")
            run_command(["./installers/auto.sh"], sudo=True)
            print(f"{GREEN}{BOLD}✅ NVIDIA installation complete.{RESET}\n")
            pause()

        elif choice == "2":
            print(f"\n{BLUE}🛠️  Manual NVIDIA driver installation...{RESET}")
            run_command(["./installers/manual.sh"], sudo=True)
            print(f"{GREEN}{BOLD}✅ Manual NVIDIA installation complete.{RESET}\n")
            pause()

        elif choice == "3":
            print(f"\n{BLUE}⬆️  Updating system...{RESET}")
            run_command(["apt", "update"], sudo=True)
            run_command(["apt", "upgrade", "-y"], sudo=True)
            print(f"{GREEN}{BOLD}✅ System update complete.{RESET}\n")
            pause()

        elif choice == "4":
            print(f"\n{BLUE}🔥 Running full installation...{RESET}")
            run_command(["apt", "update"], sudo=True)
            run_command(["apt", "upgrade", "-y"], sudo=True)
            run_command(["./installers/nvidia-installer.sh"], sudo=True)
            print(f"{GREEN}{BOLD}✅ All installations complete.{RESET}\n")
            pause()

        elif choice == "5":
            print(f"\n{RED}{BOLD}👋 Exiting. Goodbye!{RESET}\n")
            sys.exit(0)

        else:
            print(f"\n{RED}{BOLD}❌ Invalid option. Please try again.{RESET}\n")
            pause()

if __name__ == "__main__":
    main()
