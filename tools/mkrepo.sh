#!/usr/bin/env bash
# Assemble the pacman repository database and stage the gh-pages tree.
#
# Usage: tools/mkrepo.sh [outdir]
# Environment:
#   SIGN=1        also detach-sign db and packages with gpg (needs imported key)
#   KEYID         gpg key id/fingerprint to sign with
set -e

REPO_NAME="termuxvoid"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-${ROOT}/dist/any}"

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

echo "==> Collecting packages"
find "${ROOT}/packages" -name '*.pkg.tar.*' ! -name '*.sig' -exec cp -f {} "$OUT/" \;
(cd "$OUT" && rm -rf src pkg)

cd "$OUT"

echo "==> Generating ${REPO_NAME} database"
rm -f "${REPO_NAME}.db" "${REPO_NAME}.db.tar.gz" \
      "${REPO_NAME}.files" "${REPO_NAME}.files.tar.gz"
repo-add "${REPO_NAME}.db.tar.gz" ./*.pkg.tar.*

# gh-pages cannot serve symlink targets: replace db/files symlinks
# with real copies of their tarballs.
rm -f "${REPO_NAME}.db" "${REPO_NAME}.files"
cp "${REPO_NAME}.db.tar.gz" "${REPO_NAME}.db"
cp "${REPO_NAME}.files.tar.gz" "${REPO_NAME}.files"

if [ "${SIGN}" = "1" ]; then
    echo "==> Signing repository and packages"
    SIGNARGS=(--batch --yes --detach-sign)
    [ -n "${KEYID}" ] && SIGNARGS+=(--local-user "${KEYID}")
    gpg "${SIGNARGS[@]}" "${REPO_NAME}.db"
    gpg "${SIGNARGS[@]}" "${REPO_NAME}.files"
    for f in ./*.pkg.tar.*; do
        case "$f" in *.sig) continue ;; esac
        gpg "${SIGNARGS[@]}" "$f"
    done
fi

echo "==> Repository staged at ${OUT}"
ls -lh "$OUT"
