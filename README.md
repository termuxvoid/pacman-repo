<div align="center">
  <h1>TermuxVoid Pacman Repo</h1>
  <p><b>Pacman-format repository of TermuxVoid security & pentesting tools</b><br>
  Built for full pacman-bootstrap Termux (termux-pacman / termux-penv)</p>
</div>

---

## Status — pilot phase

First **6 packages** ported from the main APT repo ([TermuxVoid/repo](https://github.com/TermuxVoid/repo)) as a pipeline test. The remaining ~227 follow after validation.

| Package | Version | Install strategy |
| :--- | :--- | :--- |
| `asciibanner` | 2.1.0-1 | files shipped inside package (fonts + script) |
| `sqlmap` | 1.10.8-1 | pip, on-device |
| `commix` | 4.1-1 | git clone + pip, on-device |
| `brutespray` | 2.6.3-1 | `go install`, on-device |
| `codex-cli` | 0.148.1-1 | npm, on-device |
| `metasploit-framework` | 6.4.142-1 | pinned release + bundle install |

## Enabling the repository

Requires a **full pacman environment** (switched bootstrap or `termux-penv login termux-pacman64`). Plain `pkg install pacman` is not enough.

```bash
curl -sL https://github.com/TermuxVoid/pacman-repo/raw/main/install-repo.sh | bash
```

Or manually — add to `$PREFIX/etc/pacman.conf`:

```ini
[termuxvoid]
SigLevel = Required DatabaseOptional
Server = https://termuxvoid.github.io/pacman-repo/any
```

then import and locally sign our key:

```bash
curl -sL https://termuxvoid.github.io/pacman-repo/any/termuxvoid.gpg.asc -o /tmp/key.asc
pacman-key --add /tmp/key.asc
pacman-key --lsign-key <fingerprint printed by: gpg --show-keys /tmp/key.asc>
pacman -Syu
```

Install tools with `pacman -S <tool>`.

## How these packages are built

Each directory under `packages/<name>/` holds a PKGBUILD ported 1:1 from the Debian layout of the main repo:

| Debian (main repo) | Pacman (this repo) |
| :--- | :--- |
| `DEBIAN/control` metadata | `pkgname` / `pkgver` / `depends` / `url` / `pkgdesc` |
| `DEBIAN/preinst` | `pre_install()` in `<name>.install` |
| `DEBIAN/postinst` | `post_install()` |
| `DEBIAN/prerm` | `pre_remove()` |
| `DEBIAN/postrm` | `post_remove()` |
| `Architecture: all` | `arch=('any')` |

The heavy lifting stays on-device at install time (git clone / pip / go / npm inside `post_install()`), exactly like the apt packages — nothing is compiled here, so every `.pkg.tar.xz` stays tiny and `arch=('any')`.

### Build it yourself (AUR-style)

```bash
# inside a full pacman environment:
pacman -S base-devel git
git clone https://github.com/TermuxVoid/pacman-repo
cd pacman-repo/packages/sqlmap && makepkg -si
```

### Local pipeline test (termux-penv)

```bash
termux-penv login termux-pacman64
cd /home/pacman-repo && tools/build-all.sh && tools/mkrepo.sh dist/any
```

## Security & transparency

Unofficial community repository. Package definitions and hook scripts are published here so you can audit what runs at install/remove time before installing. Rules carried over from the main repo:

- No package modifies `$PATH`, `$HOME`, `$PREFIX`, or your dotfiles.
- Commands are exposed via symlinks or package-manager-installed entry points.
- `post_remove()` undoes only what `post_install()` created.
- Every network download and upstream reference lives inside the published hooks — read them first. Don't trust — verify.

These are dual-use security tools: use only on systems you own or are authorized to test.

## Support

- Telegram: [@nullxvoid](https://telegram.me/nullxvoid)
- Issues: [GitHub Issues](https://github.com/TermuxVoid/pacman-repo/issues)
- Main APT repository: [TermuxVoid/repo](https://github.com/TermuxVoid/repo)

---

Built for security researchers by [Alienkrishn](https://github.com/Anon4You). BSD-3-Clause.
