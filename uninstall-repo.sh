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
        echo -e "${YELLOW}${INFO} ${description} skipped (nothing to do).${RESET}"
    fi
}

command -v pacman > /dev/null 2>&1 || handle_error \
"pacman not found. Nothing to uninstall."

clear
echo -e "${MAGENTA}"
echo -e "▀▛▘               ▌ ▌   ▗   ▌"
echo -e " ▌▞▀▖▙▀▖▛▚▀▖▌ ▌▚▗▘▚▗▘▞▀▖▄ ▞▀▌"
echo -e " ▌▛▀ ▌  ▌▐ ▌▌ ▌▗▚ ▝▞ ▌ ▌▐ ▌ ▌"
echo -e " ▘▝▀▘▘  ▘▝ ▘▝▀▘▘ ▘ ▝▀ ▀▘▝▀▘"
echo -e "${RESET}"
echo -e "${CYAN}TermuxVoid Pacman Repository Uninstaller${RESET}"
echo -e ""

if [ ! -f "$PACMAN_CONF" ]; then
    handle_error "pacman.conf not found at $PACMAN_CONF"
fi

cp "$PACMAN_CONF" "$PACMAN_CONF.bak.termuxvoid" 2> /dev/null
echo -e "${INFO} Backup saved: $PACMAN_CONF.bak.termuxvoid${RESET}"

# Remove the [termuxvoid] block from pacman.conf
python3 - "$PACMAN_CONF" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
s = re.sub(r'\n?\[termuxvoid\][^\[]*', '\n', s)
open(p, 'w').write(s)
PYEOF
echo -e "${GREEN}${CHECK} Removed [termuxvoid] section from pacman.conf${RESET}"

# Locate and delete our key from the pacman keyring
FPR="$(pacman-key --list-keys 2>/dev/null | grep -B1 -iE "alienkrishn|termuxvoid" |
       grep -oE "[0-9A-F]{40}" | head -1)"
if [ -n "$FPR" ]; then
    run_command "Removing signing key ($FPR)" \
    "pacman-key --delete $FPR"
else
    echo -e "${YELLOW}${INFO} Key not found in keyring (already removed).${RESET}"
fi

run_command "Refreshing package databases" \
"pacman -Sy"

print_header "${GREEN}🎉 TermuxVoid Pacman Repository Removed! 🎉${RESET}"
echo -e "${INFO} Packages you installed remain until removed individually:${RESET}"
echo -e "${INFO}   pacman -R <tool-name>${RESET}"
echo -e "\n${CYAN}Rejoin anytime: curl -sL https://github.com/termuxvoid/pacman-repo/raw/main/install-repo.sh | bash${RESET}"
echo ""
