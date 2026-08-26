#!/usr/bin/env bash
# Build every package in packages/.
# Intended to run inside a full pacman environment
# (e.g. termux-penv login termux-pacman64).
set -e

# termux-pacman builds use xz; keep identical output across environments
export PKGEXT='.pkg.tar.xz'

cd "$(dirname "$0")/.."

for d in packages/*/; do
    [ -f "${d}PKGBUILD" ] || continue
    echo "==> Building ${d}"
    (cd "$d" && rm -rf src pkg && makepkg -f --nodeps)
done

echo "All packages built."
