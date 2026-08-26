# Contributing to TermuxVoid (Pacman Repo)

Thank you for your interest in adding a package. Before you start, make sure you understand the two core topics below. PRs may be closed without review if a submission shows these are missing.

## Prerequisites

1. **Pacman package layout.** Each package in `packages/<name>/` is a pacman-format package directory containing a `PKGBUILD`, an optional `<name>.install` hook file, and optional data archives. Understand what a `PKGBUILD` contains and when each hook function runs (`pre_install`, `post_install`, `pre_remove`, `post_remove`). See the [Termux AUR wiki](https://wiki.termux.com/wiki/AUR) and [PKGBUILD(5)](https://man.archlinux.org/man/PKGBUILD.5) if needed.

2. **Termux paths and environment.** These are used throughout the hooks:
   - `$PREFIX` → `/data/data/com.termux/files/usr` — root of the installed environment
   - `$HOME` → `/data/data/com.termux/files/home` — user home
   - `$TMPDIR` → where temporary files go; use it for scratch files
   - `$PREFIX/bin` → where user commands live
   - `$PREFIX/share/<pkg>` → where a package's data lives
   - Inside `package()`, `${terdir}` is the incomplete Termux prefix (`$pkgdir/data/data/com.termux/files`) — use it when placing files.

## Package structure

```
packages/<name>/
├── PKGBUILD           # metadata + packaging rules
├── <name>.install     # lifecycle hooks (optional but usually required)
└── <name>-data.tar.gz # files shipped inside the package (optional)
```

### PKGBUILD

Required fields:

`pkgname`, `pkgver`, `pkgrel` (use **0** so versions match upstream), `pkgdesc` (first line of upstream description), `arch=('any')`, `Maintainer` comment, `url` (upstream homepage), `depends`. List every runtime dependency under `depends`; pacman installs them for you. If a dependency does not exist in the pacman hosting, drop it from `depends` and install it inside `post_install()` instead.

Version rules:

- Pacman forbids `-` inside `pkgver`; fold such suffixes into `pkgver` with a dot or use `pkgrel`.
- Never hardcode the version twice: hooks that pin an upstream version must derive it from `$1` with the release suffix stripped: `UPVER="${1%%-*}"`.

### <name>.install

Hooks run on the user's device at install/remove time:

| Hook | Runs | Typical job |
|------|------|-------------|
| `pre_install()` | before files are placed | cheap guard checks |
| `post_install()` | after files are placed | download, build, install, link |
| `pre_remove()` | before removal | stop services, backups |
| `post_remove()` | after removal | delete files created by post_install |

**Rules to follow:**

- **Keep it simple.** One job: install the tool and expose it on `$PATH`.
- **Never** modify `$PATH`, `$HOME`, `$PREFIX`, or any other environment variable.
- **Never** touch the user's existing Termux config or dotfiles.
- Expose commands via **symlinks into `$PREFIX/bin`**. Prefer a `ln -s` over a wrapper script.
- The final job of `post_install()` is to verify the command exists; `return 1` on any failure.

Example (Go tool):

```bash
post_install() {
    set -e

    UPVER="${1%%-*}"

    go install -trimpath "github.com/example/tool@v${UPVER}"

    if [ ! -f "$PREFIX/bin/tool" ] && [ -f "$HOME/go/bin/tool" ]; then
        ln -sf "$HOME/go/bin/tool" "$PREFIX/bin/tool"
    fi
}

post_remove() {
    rm -f "$HOME/go/bin/tool" "$PREFIX/bin/tool"
}
```

Native-gem rule: any hook that runs `gem install` / `bundle install` must first `export NOKOGIRI_USE_SYSTEM_LIBRARIES=1`, and bare `gem install <tool>` calls should pass trailing `-- --use-system-libraries`. Otherwise nokogiri (a transitive dependency of many gems) rebuilds its bundled C sources against missing headers and the install fails. See `wpscan.install` for the pattern.

### Data files

If the package ships files (fonts, scripts, themes), tar them as `<name>-data.tar.gz`, reference them via `source=` with a real `sha256sums`, and extract into `$pkgdir` inside `package()`:

```bash
source=("<name>-data.tar.gz")
sha256sums=('SKIP')

package() {
    tar -xzf "${srcdir}/<name>-data.tar.gz" -C "${pkgdir}"
}
```

We use `SKIP` for shipped data (same policy as the APT repo): manually maintained hashes drift out of sync and break builds without adding safety — the git history is the integrity record.

The archive's internal paths **must be PREFIX-relative** (`usr/bin/foo`, `share/<pkg>/...`) — never absolute `data/data/com.termux/...` paths. Pacman's root is `$PREFIX` on real pacman-bootstrap devices, so absolute paths fail to extract there (this matches how termux-pacman ships its own packages). Generate archives with:

```bash
tar -czf <name>-data.tar.gz -C <src>/data/data/com.termux/files .
```

### Writable locations

Only `$PREFIX`, `$HOME`, and `$TMPDIR` are writable at hook time. Always `mkdir -p` before writing into a subdirectory, and never reference raw `/data/data/...` or other absolute system paths inside hooks.

## Test before submitting

Build and test inside a full pacman environment (real switched bootstrap or `termux-penv login termux-pacman64`):

```bash
pacman -S base-devel git
cd packages/<name>
makepkg -f --nodeps

# 1. Package builds cleanly for arch ('any')
# 2. Install, run, remove:
pacman -U ./*.pkg.tar.xz
tool --version

# 3. Nothing env-related was modified
echo "$PATH"      # unchanged after install

# 4. Uninstall leaves no trace
pacman -R <name>
test ! -e "$PREFIX/bin/tool"
```

Also validate repository-wide: `tools/build-all.sh && tools/mkrepo.sh dist/any`.

## PR checklist

- [ ] Correct layout (`packages/<name>/PKGBUILD` plus `.install` hooks).
- [ ] All runtime dependencies declared under `depends` (or handled inside `post_install()` with a comment why).
- [ ] Version pins use `UPVER="${1%%-*}"`, never raw `$1`.
- [ ] `post_install()` keeps to one job, uses symlinks, and does **not** change any environment variable or path.
- [ ] Removal hooks undo exactly what the install hooks created.
- [ ] Built, installed, ran, and uninstalled successfully during testing.
- [ ] Added to `assets/PACKAGES.md` under the correct category.

If unsure about any step, ask before opening the PR rather than guessing.
