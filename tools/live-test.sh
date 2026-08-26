#!/bin/bash
set -e
LOG=/tmp/live.log
: > "$LOG"

cat > /tmp/live-pacman.conf <<EOF
[options]
Architecture = aarch64
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
DBPath = /tmp/livetest/db
CacheDir = /tmp/livetest/cache

[termuxvoid]
Server = https://termuxvoid.github.io/pacman-repo/any
EOF

mkdir -p /tmp/livetest/db /tmp/livetest/cache
curl -sL https://termuxvoid.github.io/pacman-repo/any/termuxvoid.gpg.asc -o /tmp/key.asc
test -s /tmp/key.asc && echo "KEY DOWNLOAD OK" >> "$LOG"

pacman-key --init > /dev/null 2>&1 || true
pacman-key --add /tmp/key.asc && echo "KEY ADD OK" >> "$LOG"

FPR="$(gpg --show-keys --with-colons /tmp/key.asc | awk -F: '$1=="fpr"{print $10; exit}')"
echo "FPR: $FPR" >> "$LOG"
pacman-key --lsign-key "$FPR" && echo "KEY LSIGN OK" >> "$LOG"

pacman --config /tmp/live-pacman.conf -Sy && echo "SYNC OK" >> "$LOG"
pacman --config /tmp/live-pacman.conf -Sl termuxvoid >> "$LOG" 2>&1
