#!/bin/bash

# ====== Colors ======
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
BOLD="\e[1m"

clear

# ====== Banner ======
echo -e "${MAGENTA}${BOLD}"
echo "██████╗  ██████╗ ████████╗██╗  ██╗██████╗ ██████╗  █████╗ ██╗███╗   ██╗"
echo "██╔══██╗██╔═══██╗╚══██╔══╝╚██╗██╔╝██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║"
echo "██║  ██║██║   ██║   ██║    ╚███╔╝ ██████╔╝██████╔╝███████║██║██╔██╗ ██║"
echo "██║  ██║██║   ██║   ██║    ██╔██╗ ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║"
echo "██████╔╝╚██████╔╝   ██║   ██╔╝ ██╗██████╔╝██║  ██║██║  ██║██║██║ ╚████║"
echo "╚═════╝  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝"
echo -e "${RESET}"

# ====== Password Protection (after banner) ======
read -s -p $'\e[36mEnter password to access DOTXBRAIN:\e[0m ' USER_PASS
echo
HASHED_PASS="00682f359daf6c370e13b8ac81330ca6285215941e06473b728f5838bf175d64"
USER_HASH=$(echo -n "$USER_PASS" | sha256sum | awk '{print $1}')

if [[ "$USER_HASH" != "$HASHED_PASS" ]]; then
    echo -e "${RED}[-] Incorrect password. Access denied.${RESET}"
    exit 1
fi

# ====== Links ======
echo -e "${YELLOW}YouTube:  ${CYAN}https://youtube.com/@dotxbrain${RESET}"
echo -e "${YELLOW}Telegram: ${CYAN}https://t.me/dotxbrain${RESET}"

# ====== Dependency Check ======
echo -e "${MAGENTA}[+] Checking for SSH...${RESET}"
if ! command -v ssh &> /dev/null; then
    echo -e "${YELLOW}[~] SSH not found. Installing...${RESET}"
    sudo apt update && sudo apt install -y openssh-client
else
    echo -e "${GREEN}[✓] SSH is installed.${RESET}"
fi

# ====== Input Section ======
echo -ne "${BOLD}${BLUE}Enter subdomain to use (e.g. mysub): ${RESET}"; read SUBDOMAIN
xdg-open "https://youtube.com/@dotxbrain" &>/dev/null

echo -ne "${BOLD}${BLUE}Enter local port to forward (e.g. 8080): ${RESET}"; read PORT
xdg-open "https://t.me/dotxbrain" &>/dev/null

echo -ne "${BOLD}${BLUE}Do you want to generate a new SSH key? (y/n): ${RESET}"; read GEN_KEY

KEY_PATH="$HOME/.ssh/serveo_key"

if [[ "$GEN_KEY" == "y" ]]; then
    echo -e "${YELLOW}[~] Generating SSH key...${RESET}"
    rm -f "$KEY_PATH" "$KEY_PATH.pub"
    ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""
else
    if [[ -f "$KEY_PATH" ]]; then
        echo -e "${GREEN}[✓] Existing Serveo key found: $KEY_PATH${RESET}"
    else
        echo -ne "${BOLD}${BLUE}Enter full path of your existing private SSH key: ${RESET}"; read KEY_PATH
        if [[ ! -f "$KEY_PATH" ]]; then
            echo -e "${RED}[-] SSH key not found at $KEY_PATH. Exiting.${RESET}"
            exit 1
        fi
    fi
fi

# ====== Start Serveo Tunnel ======
echo -e "${MAGENTA}[+] Starting Serveo tunnel...${RESET}"
chmod 600 "$KEY_PATH"
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -R "$SUBDOMAIN.serveo.net:80:localhost:$PORT" serveo.net
