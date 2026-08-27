#!/data/data/com.termux/files/usr/bin/bash

PACMAN_CONF="${PREFIX:-/data/data/com.termux/files/usr}/etc/pacman.conf"

python3 - "$PACMAN_CONF" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
s = re.sub(r'\n?\[termuxvoid\][^\[]*', '\n', s)
open(p, 'w').write(s)
PYEOF

FPR="$(pacman-key --list-keys 2>/dev/null | grep -B1 -iE "alienkrishn|termuxvoid" | grep -oE "[0-9A-F]{40}" | head -1)"
if [ -n "$FPR" ]; then
    pacman-key --delete "$FPR" 2>/dev/null || true
fi

pacman -Sy

echo ""
echo "Thank you for using TermuxVoid."
echo "TermuxVoid pacman repository has been removed from your Termux environment."
