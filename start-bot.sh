#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

# DOTXBRAIN Branding
echo -e "${CYAN}"
echo "    ____  ____  _______  __ ____  ____  ___    _____   __"
echo "   / __ \/ __ \/_  __/ |/ // __ )/ __ \/   |  /  _/ | / /"
echo "  / / / / / / / / /  |   // __  / /_/ / /| |  / //  |/ / "
echo " / /_/ / /_/ / / /  /   |/ /_/ / _, _/ ___ |_/ // /|  /  "
echo "/_____/\____/ /_/  /_/|_/_____/_/ |_/_/  |_/___/_/ |_/   "
echo -e "${GREEN}     Telegram Bot Secure Launcher by DOTXBRAIN${RESET}"
echo

# Step 1: Ask User Login
read -p "Enter User ID: " input_user
read -sp "Enter Password: " input_pass
echo

# Step 2: Fetch remote credentials from GitHub
GITHUB_TOKEN="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"
RAW_URL="https://raw.githubusercontent.com/munna7320/dotxbrain-auth/refs/heads/main/auth.txt?token=GHSAT0AAAAAADELJUI3637UGZA2KZKCIGAO2BUITCQ"

auth_data=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$RAW_URL")
remote_user=$(echo "$auth_data" | grep userid | cut -d'=' -f2 | tr -d '\r')
remote_pass=$(echo "$auth_data" | grep password | cut -d'=' -f2 | tr -d '\r')

# Step 3: Authenticate
if [[ "$input_user" != "$remote_user" || "$input_pass" != "$remote_pass" ]]; then
  echo -e "${RED}Access Denied: Invalid user ID or password.${RESET}"
  exit 1
fi

echo -e "${GREEN}Access Granted. Welcome $input_user${RESET}"
sleep 1

# Step 4: Auto-download index.js and package.json if not present
INDEX_URL="https://raw.githubusercontent.com/munna7320/Dotxbrain/refs/heads/main/index.js"
PACKAGE_URL="https://raw.githubusercontent.com/munna7320/Dotxbrain/refs/heads/main/package.json"

if [[ -f "index.js" ]]; then
  echo -e "${GREEN}index.js already exists.${RESET}"
else
  echo -e "${CYAN}Downloading index.js...${RESET}"
  curl -s -H "Authorization: token $GITHUB_TOKEN" -o index.js "$INDEX_URL"
  echo -e "${GREEN}index.js downloaded.${RESET}"
fi

if [[ -f "package.json" ]]; then
  echo -e "${GREEN}package.json already exists.${RESET}"
else
  echo -e "${CYAN}Downloading package.json...${RESET}"
  curl -s -H "Authorization: token $GITHUB_TOKEN" -o package.json "$PACKAGE_URL"
  echo -e "${GREEN}package.json downloaded.${RESET}"
fi

# Ask user if they want to update token/id
read -p "Do you want to update the token and chat ID? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  read -p "Enter new Telegram Bot Token: " new_token
  read -p "Enter new Telegram Chat ID: " new_chatid

  if grep -q "const token" index.js && grep -q "const id" index.js; then
    cp index.js index.js.bak

    sed -i -E "s|(const token\\s*=\\s*[\"']).*([\"'])|\\1${new_token}\\2|" index.js
    sed -i -E "s|(const id\\s*=\\s*[\"']).*([\"'])|\\1${new_chatid}\\2|" index.js

    if grep -q "${new_token}" index.js && grep -q "${new_chatid}" index.js; then
      echo -e "${GREEN}Success: token and id updated in index.js${RESET}"
    else
      echo -e "${RED}Unsuccess: Failed to update token or id.${RESET}"
      mv index.js.bak index.js
      exit 1
    fi
  else
    echo -e "${RED}Unsuccess: Could not find 'token' or 'id' in index.js${RESET}"
    exit 1
  fi
else
  echo -e "${CYAN}Token update skipped.${RESET}"
fi

# Install dependencies
echo -e "${CYAN}Installing dependencies...${RESET}"
npm install

# Run the bot
echo -e "${CYAN}Starting bot...${RESET}"

echo -e "${GREEN}Bot linked. Start your hacking. Thank you DOTXBRAIN.${RESET}"

node index.js package.json

