#!/data/data/com.termux/files/usr/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"
CHECK="✅"
CROSS="❌"
INFO=">> "

PACMAN_CONF="${PREFIX:-/data/data/com.termux/files/usr}/etc/pacman.conf"
REPO_URL="https://termuxvoid.github.io/pacman-repo/any"
KEY_URL="https://termuxvoid.github.io/pacman-repo/any/termuxvoid.gpg.asc"

print_header() {
    echo -e "\n${BLUE}========================================${RESET}"
    echo -e "$1"
    echo -e "${BLUE}========================================${RESET}"
}

handle_error() {
    echo -e "\n${RED}${CROSS} Error: $1${RESET}"
    exit 1
}

run_command() {
    local description="$1" command="$2"
    echo -e "${YELLOW}${INFO} ${description}...${RESET}"
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} ${description} completed successfully!${RESET}"
    else
        handle_error "Failed to ${description,,}"
    fi
}

command -v pacman > /dev/null 2>&1 || handle_error \
"pacman not found. This repository requires the full pacman bootstrap
    (switch package manager or use termux-penv: https://wiki.termux.com/wiki/AUR)"

clear
echo -e "${MAGENTA}"
echo -e "▀▛▘               ▌ ▌   ▗   ▌"
echo -e " ▌▞▀▖▙▀▖▛▚▀▖▌ ▌▚▗▘▚▗▘▞▀▖▄ ▞▀▌"
echo -e " ▌▛▀ ▌  ▌▐ ▌▌ ▌▗▚ ▝▞ ▌ ▌▐ ▌ ▌"
echo -e " ▘▝▀▘▘  ▘▝ ▘▝▀▘▘ ▘ ▝▀ ▀▘▝▀▘"
echo -e "${RESET}"
echo -e "${CYAN}TermuxVoid Pacman Repository Installer${RESET}"
echo -e ""

run_command "Backing up pacman.conf" \
"cp $PACMAN_CONF $PACMAN_CONF.bak.termuxvoid"

if grep -q "^\[termuxvoid\]" "$PACMAN_CONF" 2> /dev/null; then
    echo -e "${GREEN}${CHECK} [termuxvoid] already present in pacman.conf${RESET}"
else
    run_command "Adding TermuxVoid repository to pacman.conf" \
"printf '\n[termuxvoid]\nSigLevel = Required DatabaseOptional\nServer = $REPO_URL\n' >> $PACMAN_CONF"
fi

TMPKEY="$(mktemp)"
trap 'rm -f "$TMPKEY"' EXIT

run_command "Downloading TermuxVoid GPG key" \
"curl -sL $KEY_URL -o $TMPKEY && test -s $TMPKEY"

echo -e "${YELLOW}${INFO} Importing key into pacman keyring...${RESET}"
pacman-key --add "$TMPKEY" || handle_error "Failed to import GPG key"

FPR="$(gpg --show-keys --with-colons "$TMPKEY" 2>/dev/null |
       awk -F: '$1=="fpr"{print $10; exit}')"
[ -n "$FPR" ] || handle_error "Could not read key fingerprint"

run_command "Locally signing key ($FPR)" \
"pacman-key --lsign-key $FPR"

run_command "Refreshing package databases" \
"pacman -Sy"

print_header "${GREEN}🎉 TermuxVoid Pacman Repository Setup Complete! 🎉${RESET}"
echo -e "${INFO} Install tools with:  pacman -S <tool-name>${RESET}"
echo -e "${INFO} Example:             pacman -S sqlmap${RESET}"
echo -e "${INFO} Join our Telegram channel for updates:"
echo -e "${BLUE}https://telegram.me/nullxvoid/${RESET}"
echo ""
