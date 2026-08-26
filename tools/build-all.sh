#!/usr/bin/env bash
# Build every package in packages/ (arch-independent).
# Intended to run inside a full pacman environment
# (e.g. termux-penv login termux-pacman64).
#
# Env:
#   JOBS=N   build N packages in parallel (default 1)
set -u

export PKGEXT='.pkg.tar.xz'
JOBS="${JOBS:-1}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

build_one() {
    local d="$1"
    # resumable: skip packages that already have a built artifact
    if ls "${d}"*.pkg.tar.xz > /dev/null 2>&1; then
        echo "==> Skipping ${d} (already built)"
        return 0
    fi
    echo "==> Building ${d}"
    (
        cd "$d" && rm -rf src pkg && makepkg -f --nodeps
    )
}
export -f build_one 2>/dev/null

if [ "$JOBS" -gt 1 ] && command -v xargs > /dev/null 2>&1; then
    for d in packages/*/; do
        [ -f "${d}PKGBUILD" ] && printf '%s\n' "$d"
    done | xargs -P "$JOBS" -I{} bash -c 'build_one "$@"' _ {}
else
    for d in packages/*/; do
        [ -f "${d}PKGBUILD" ] || continue
        build_one "$d"
    done
fi

echo "All packages built."
