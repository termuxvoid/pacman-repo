#!/usr/bin/env bash
# Assemble the pacman repository database and stage the gh-pages tree.
#
# Usage: tools/mkrepo.sh [distdir]
# Environment:
#   SIGN=1     detach-sign db and packages (needs an imported gpg key)
#   KEYID      gpg key id/fingerprint to sign/export with
set -eu

REPO_NAME="termuxvoid"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${1:-${ROOT}/dist}"
mkdir -p "$DIST"
DIST="$(cd "$DIST" && pwd)"
OUT="$DIST/any"
mkdir -p "$OUT"

echo "==> Collecting built packages"
find "${ROOT}/packages" -name '*.pkg.tar.xz' ! -name '*.sig' \
    ! -name '.*' -exec cp -f {} "$OUT/" \;
echo "    $(ls "$OUT"/*.pkg.tar.xz 2>/dev/null | wc -l) packages"

cd "$OUT"

echo "==> Generating ${REPO_NAME} database"
rm -f "${REPO_NAME}.db" "${REPO_NAME}.db.tar.gz" \
      "${REPO_NAME}.files" "${REPO_NAME}.files.tar.gz"
repo-add "${REPO_NAME}.db.tar.gz" ./*.pkg.tar.xz

# gh-pages cannot serve symlink targets: replace db/files symlinks
# with real copies of their tarballs.
rm -f "${REPO_NAME}.db" "${REPO_NAME}.files"
cp "${REPO_NAME}.db.tar.gz" "${REPO_NAME}.db"
cp "${REPO_NAME}.files.tar.gz" "${REPO_NAME}.files"

if [ "${SIGN:-0}" = "1" ]; then
    echo "==> Signing repository and packages"
    SIGNARGS=(--batch --yes --detach-sign)
    [ -n "${KEYID:-}" ] && SIGNARGS+=(--local-user "${KEYID}")
    gpg "${SIGNARGS[@]}" "${REPO_NAME}.db"
    gpg "${SIGNARGS[@]}" "${REPO_NAME}.files"
    for f in ./*.pkg.tar.xz; do
        gpg "${SIGNARGS[@]}" "$f"
    done
    echo "==> Exporting public key"
    gpg --armor --export "${KEYID:-}" > "$DIST/termuxvoid.gpg.asc"
fi

echo "==> Repository staged at ${OUT} ($(ls | wc -l) files)"
