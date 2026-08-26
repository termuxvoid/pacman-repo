#!/data/data/com.termux/files/usr/bin/bash
# Port TermuxVoid APT packages (deb layout) into pacman PKGBUILDs.
#
# Usage: tools/convert.sh <src-repo> <dest-repo> [package ...]
#   src : repo containing packages/<name>/DEBIAN   (default ~/repo)
#   dest: this pacman repo                          (default ~/pacman-repo)
#
# Conversion rules (see README):
#   control      -> PKGBUILD vars
#   preinst      -> pre_install()     prerm -> pre_remove()
#   postinst     -> post_install()    postrm -> post_remove()
#   data/ tree   -> <name>-data.tar.gz + sha256sums, extracted in package()
#   version dash -> numeric tail becomes pkgrel, otherwise folded into pkgver
set -u

SRC="${1:-$HOME/repo}"
DEST="${2:-$HOME/pacman-repo}"
shift 2 2>/dev/null || shift $# 2>/dev/null
PKGS="$*"

MAINTAINER="Alienkrishn [Anon4You]"

die() { echo "convert: ERROR: $*" >&2; exit 1; }
[ -d "$SRC/packages" ] || die "no packages/ dir in $SRC"

sh_quote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

sanitize_version() {
    local v="${1//[[:space:]]/}" ver rel tail
    v="${v%%\$}" # paranoia
    if [[ "$v" == *-* ]]; then
        ver="${v%-*}"
        tail="${v##*-}"
        if [[ "$tail" =~ ^[0-9]+$ ]]; then
            REL="$tail"
        else
            REL=0
            ver="${ver}.${tail}"
        fi
        ver="${ver//-/.}"
    else
        ver="$v"; REL=0
    fi
    # pacman allows alnum . _ + only
    local bad="${ver//[^A-Za-z0-9._+]/}"
    if [ "$bad" != "$ver" ]; then
        echo "  WARN: sanitized pkgver '$ver' -> '$bad'" >&2
        ver="$bad"
    fi
    VER="$ver"
}

control_field() { # $1=file $2=field -> prints joined value (continuations merged)
    awk -v F="$2" '
        /^[A-Za-z][A-Za-z0-9-]*:/ {
            key=$0; sub(/:.*/,"",key)
            val=$0; sub(/^[^:]*:[ ]?/,"",val)
            inf=(key==F)
            if (inf) out=val
            next
        }
        inf && /^[ \t]/ { gsub(/^[ \t]+/,""); out=out" "$0 }
        END { print out }
    ' "$1"
}

first_desc_line() {
    awk '/^Description:/{sub(/^Description:[ ]?/,""); print; exit}' "$1"
}

emit_install() { # $1=src pkg dir  $2=name  $3=dest dir ; returns 0 if written
    local d="$1/DEBIAN" name="$2" out="$3" pair fn body wrote=0
    local -A MAP=( [preinst]=pre_install [postinst]=post_install \
                   [prerm]=pre_remove [postrm]=post_remove )
    [ -f "$d/poatrm" ] && echo "  NOTE: typo script DEBIAN/poatrm treated as postrm" >&2
    [ -f "$d/poatrm" ] && d="$d" # handled below by aliasing

    {
        echo '#!/bin/bash'
        echo ''
        for src in preinst postinst prerm postrm poatrm; do
            f="$d/$src"
            [ -f "$f" ] || continue
            case "$src" in poatrm) fn="post_remove";; *) fn="${MAP[$src]}";; esac
            echo "${fn}() {"
            body="$(sed -E \
                -e '/^#![\/]/d' \
                -e 's/^([[:space:]]*)exit[[:space:]]+([0-9]+)[[:space:]]*$/\1return \2/' \
                -e 's/^([[:space:]]*)exit[[:space:]]*$//' "$f")"
            echo "$body"
            echo '}'
            echo ''
            wrote=1
        done
    } > "$out"
    [ "$wrote" = 1 ]
}

port_one() {
    local p="$1"
    local srcdir="$SRC/packages/$p" outdir="$DEST/packages/$p"
    local ctl="$srcdir/DEBIAN/control"
    [ -f "$ctl" ] || { echo "SKIP $p (no control)"; return 0; }

    if [ -d "$outdir" ] && [ "${FORCE:-0}" != "1" ]; then
        echo "SKIP $p (already ported)"
        return 0
    fi

    local name ver homepage desc depstring
    name="$(awk -F': ' '/^Package:/{print $2; exit}' "$ctl" | tr -d '[:space:]')"
    [ -n "$name" ] || { echo "FAIL $p: no Package field"; FAILED=$((FAILED+1)); return 0; }
    rawver="$(control_field "$ctl" Version)"
    [ -n "$rawver" ] || { echo "FAIL $p: no Version"; FAILED=$((FAILED+1)); return 0; }
    sanitize_version "$rawver"
    homepage="$(control_field "$ctl" Homepage | tr -d '[:space:]')"
    desc="$(first_desc_line "$ctl")"
    depstring="$(control_field "$ctl" Depends)"

    mkdir -p "$outdir"

    # ---- hooks ----
    local installvar="" instfile=""
    if emit_install "$srcdir" "$name" "$outdir/$name.install"; then
        installvar="install=\"${name}.install\""
    fi

    # ---- data tarball ----
    local srclines=() sumlines=() pkgbody='    return 0'
    if [ -d "$srcdir/data" ]; then
        # Pack PREFIX-RELATIVE (usr/..., etc/...) like termux-pacman packages:
        # pacman RootDir is "/" on termux-pacman, so package payloads must
        # carry the full data/data/com.termux/files prefix to land in $PREFIX.
        tar -czf "$outdir/${name}-data.tar.gz" -C "$srcdir/data/data/com.termux/files" .
        # No integrity pinning (mirrors the APT repo): hashes of manually
        # packed data drift out of sync and break builds for new ports.
        srclines=("source=(${name}-data.tar.gz)")
        sumlines=("sha256sums=('SKIP')")
        # Retarget PREFIX-RELATIVE payload -> ABSOLUTE device paths.
        # (termux-pacman's makepkg does this via terdir="$pkgdir$TERMUX_BASE_DIR";
        #  stock Arch makepkg used by this repo has no equivalent.)
        pkgbody='    mkdir -p "${pkgdir}/data/data/com.termux/files"
    tar -xzf "${srcdir}/'"${name}"'-data.tar.gz" -C "${pkgdir}/data/data/com.termux/files"'
    fi

    # ---- depends ----
    local deparr=""
    if [ -n "$depstring" ]; then
        deparr="$(printf '%s' "$depstring" | tr ',' '\n' | sed 's/[[:space:]]\+/ /g;s/^ //;s/ $//' |
                  grep -v '^$' | awk '{printf "%s'\''%s'\''", (NR>1?" ":""), $0}')"
        deparr="depends=(${deparr})"
    fi

    # ---- emit PKGBUILD ----
    {
        echo "# Maintainer: ${MAINTAINER}"
        echo "# Ported from TermuxVoid APT repo (packages/${name})"
        echo ""
        echo "pkgname=\"${name}\""
        echo "pkgver=${VER}"
        echo "pkgrel=${REL}"
        echo "pkgdesc=$(sh_quote "${desc:-TermuxVoid tool}")"
        echo "arch=('any')"
        [ -n "$homepage" ] && echo "url=\"${homepage}\""
        [ -n "$deparr" ] && echo "$deparr"
        [ -n "$installvar" ] && echo "$installvar"
        echo "options=('!strip' '!debug' '!emptydirs')"
        if [ ${#srclines[@]} -gt 0 ]; then
            echo "${srclines[0]}"
            echo "${sumlines[0]}"
        fi
        cat <<EOF

build() {
    return 0
}

package() {
${pkgbody}
}
EOF
    } > "$outdir/PKGBUILD"

    echo "OK $p ($rawver -> ${VER}-${REL})"
}

FAILED=0
if [ -n "$PKGS" ]; then
    for p in $PKGS; do port_one "$p"; done
else
    for d in "$SRC"/packages/*/; do
        port_one "$(basename "$d")"
    done
fi
echo "---"
echo "conversion failures: $FAILED"
