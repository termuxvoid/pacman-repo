#!/usr/bin/env python3
"""One-shot migration: retarget all PKGBUILDs for termux-pacman RootDir=/.

- options=('!strip')          -> options=('!strip' '!debug' '!emptydirs')
                                   ('!debug' kills makepkg's phantom usr/src/debug/<pkg>)
- data-extract package():     -> extract under $pkgdir/data/data/com.termux/files
                                   (matches official gpkg/tur payload layout)
- pkgrel=N                    -> pkgrel=1 (so installed -0/-N packages upgrade)
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = "data/data/com.termux/files"

changed = skipped = 0
for pkgb in sorted(ROOT.glob("packages/*/PKGBUILD")):
    text = orig = pkgb.read_text()

    # 1) options
    text = text.replace(
        "options=('!strip')",
        "options=('!strip' '!debug' '!emptydirs')", 1,
    )

    # 2) data-extract retarget
    m = re.search(r'tar -xzf "\$\{srcdir\}/([A-Za-z0-9._+-]+)-data\.tar\.gz" -C "\$\{pkgdir\}"', text)
    if m:
        name = m.group(1)
        old = f'tar -xzf "${{srcdir}}/{name}-data.tar.gz" -C "${{pkgdir}}"'
        new = (f'mkdir -p "${{pkgdir}}/{BASE}"\n'
               f'    tar -xzf "${{srcdir}}/{name}-data.tar.gz" -C "${{pkgdir}}/{BASE}"')
        text = text.replace(old, new, 1)

    # 3) pkgrel bump (any numeric value -> 1); idempotent on re-run
    text = re.sub(r'(?m)^pkgrel=\d+$', 'pkgrel=1', text)

    if text != orig:
        pkgb.write_text(text)
        changed += 1
    else:
        skipped += 1

print(f"changed={changed} unchanged={skipped}")
sys.exit(0)
