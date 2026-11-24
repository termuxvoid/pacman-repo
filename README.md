<div align="center">
  <a href="https://termuxvoid.github.io/">
    <img alt="TermuxVoid" height="170" src="img/termuxvoid_logo.png">
    <h1>TermuxVoid Pacman Repository</h1>
  </a>
  <p><b>An independent third-party Termux software ecosystem with 250+ security, Android, AI, and utility tools</b></p>

  <div>
    <a href="https://termuxvoid.github.io/">
      <img src="https://img.shields.io/badge/Website-termuxvoid.github.io-2ea44f?style=for-the-badge&logo=githubpages&logoColor=white" alt="Website">
    </a>
    <a href="https://github.com/TermuxVoid/pacman-repo/stargazers">
      <img src="https://img.shields.io/github/stars/TermuxVoid/pacman-repo?style=for-the-badge&logo=github&color=ffd700&labelColor=0d1117" alt="GitHub Stars">
    </a>
    <a href="https://github.com/TermuxVoid/pacman-repo/blob/main/LICENSE">
      <img src="https://img.shields.io/badge/License-BSD_3--Clause-blue?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License">
    </a>
    <a href="https://github.com/TermuxVoid/pacman-repo/issues">
      <img src="https://img.shields.io/github/issues/TermuxVoid/pacman-repo?style=for-the-badge&logo=github&color=orange&labelColor=0d1117" alt="GitHub Issues">
    </a>
    <a href="https://t.me/termuxvoid">
      <img src="https://img.shields.io/badge/Telegram-@termuxvoid-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram">
    </a>
  </div>
</div>

**TermuxVoid** is an independent third-party Termux software ecosystem. The Pacman side packages **250+ security, Android, AI, and utility tools** that are missing from, or deliberately excluded by, the official Termux repositories.

- **One command to set up** — adds the repository, imports and locally signs the key, and installs the packaging prerequisites.
- **Native Termux packaging** — tools are exposed through `$PREFIX/bin`; no root required unless a tool explicitly asks for it.
- **Signed packages** — pacman verifies package signatures; the database signature is optional (`SigLevel = Required DatabaseOptional`).
- **Same catalog on APT** — the identical package set is available from the [APT repository](https://github.com/termuxvoid/repo).

> [!IMPORTANT]
> This is a community project, not an official Termux repository. A full Pacman bootstrap (or `termux-penv`) is required; the installer will stop if `pacman` is not present.
>
> Do not report TermuxVoid package issues to the official Termux project. They do not maintain this repository, so the report will not reach the right maintainers and only wastes everyone's time. Use [GitHub Issues](https://github.com/TermuxVoid/pacman-repo/issues) instead.

## Contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Usage](#usage)
- [Package catalog](#package-catalog)
- [How packages work](#how-packages-work)
- [Security](#security)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)

## Requirements

- **Termux** with a working **Pacman** environment, such as the full Pacman bootstrap or [termux-penv](https://wiki.termux.com/wiki/AUR). The standard `pkg`/APT setup cannot use this repository.
- **Android 7.0 or newer**.
- A working network connection.
- Free storage. Some tools compile on device or download large upstream bundles, so installation size varies by package.

## Quick start

### 1. Add the repository

```bash
curl -fsSL https://v.gd/termuxvoid_pacman | bash
```

The installer backs up `pacman.conf`, adds the signed `[termuxvoid]` repository, imports and locally signs the TermuxVoid GPG key, refreshes the databases, installs the build prerequisites (`base-devel`, `gcc-libs-glibc`), links the glibc `resolv.conf`, and installs **tvpkg** (`tvp`), the TermuxVoid package manager.

> [!WARNING]
> Piping a remote script to `bash` executes it immediately. If you want to inspect it first, review [`install-repo.sh`](https://github.com/termuxvoid/pacman-repo/blob/main/install-repo.sh) before running it.

### 2. Install a tool

```bash
pacman -Syu
pacman -S metasploit-framework
```

Replace `metasploit-framework` with any package from the [catalog](assets/PACKAGES.md).

### 3. Keep packages up to date

```bash
pacman -Syu
```

## Usage

| Task | Command |
| :--- | :--- |
| Refresh databases and upgrade | `pacman -Syu` |
| Search the catalog | `pacman -Ss <term>` |
| Install a tool | `pacman -S <tool-name>` |
| Remove a tool | `pacman -Rns <tool-name>` |
| Open the TermuxVoid TUI | `tvpkg` or `tvp` |

**tvpkg** is an interactive terminal UI for browsing, installing, and removing TermuxVoid packages.

### Remove the repository

```bash
curl -fsSL https://github.com/termuxvoid/pacman-repo/raw/main/uninstall-repo.sh | bash
```

This removes the TermuxVoid repository entry and signing key. Packages you have already installed are left untouched.

### Using APT instead?

The same 250+ packages are available from the [APT repository](https://github.com/termuxvoid/repo):

```bash
curl -fsSL https://v.gd/termuxvoid_apt | bash
```

## Package catalog

<div align="center">
  <a href="assets/PACKAGES.md">
    <img src="https://img.shields.io/badge/Browse_All_250%2B_Tools-2ea44f?style=for-the-badge" alt="Browse All Tools">
  </a>
</div>

The full, always-current list is in [`assets/PACKAGES.md`](assets/PACKAGES.md). The [website](https://termuxvoid.github.io/) reads the same repository index and lets you search it by name, category, or description.

### Featured tools

| Tool | Package | Category | Description |
| :--- | :--- | :--- | :--- |
| **Metasploit Framework** | `metasploit-framework` | Security & exploitation | Penetration testing framework. |
| **Burp Suite** | `burpsuite` | Web security | Web application security testing platform. |
| **Ghidra** | `ghidra` | Reverse engineering | Software reverse-engineering suite. |
| **THC Hydra** | `thc-hydra` | Networking | Parallelized login cracker. |
| **SQLMap** | `sqlmap` | Web security | SQL injection detection and exploitation. |
| **John the Ripper** | `john` | Password tools | Password cracker. |

### AI and developer tools

AI tools may require accounts or API keys, may send data to third-party providers, and can produce incorrect output. Review generated code before running it.

| Package | Description |
| :--- | :--- |
| **9router** | Gateway between your tools and AI providers |
| **antigravity-cli** | AI coding assistant (glibc wrapper for Termux) |
| **claude-code** | Claude Code - AI coding assistant by Anthropic |
| **codex-cli** | Codex CLI - AI coding agent (npm version) |
| **copilot-cli** | GitHub Copilot CLI |
| **deepseek-harness** | DeepSeek Harness - AI coding agent with local web UI |
| **freebuff** | AI coding agent for the terminal |
| **hermes-agent** | AI coding assistant and workflow automation tool |
| **jcode** | Terminal coding agent harness |
| **kimi-code** | AI coding assistant for the terminal |
| **laudacode** | Lightweight AI coding agent for your terminal |
| **mimocode** | AI coding agent (glibc wrapper for Termux) |
| **mmx-cli** | CLI for MiniMax AI |
| **openclaude** | Open-source coding-agent CLI for cloud and local LLMs |
| **opencode** | AI-powered coding assistant |
| **opencode-v2** | OpenCode 2 - AI coding agent (glibc version) |
| **termux-ai** | Interactive AI assistant for Termux |
| **utim-cli** | AI-powered unified terminal intelligence manager |

## How packages work

Each entry in `packages/` is a lightweight PKGBUILD. During installation, its install script either downloads a pinned upstream release or builds the tool from source, then exposes the executable through `$PREFIX/bin`.

This approach keeps the repository small and avoids shipping stale binaries, but it means:

- Installation can take time, especially for tools that compile on device.
- Disk usage varies widely, from a few megabytes to several hundred.
- The package script is the source of truth for what gets downloaded or built.

Read the relevant `PKGBUILD` and `.install` file before installing a package you do not trust. Fixed-version downloads use pinned SHA-256 checksums where upstream provides stable artifacts.

## Security

This is an independent, third-party project, not affiliated with or endorsed by the Termux project. Package scripts run with your permissions, so read the script before installing. Some packages compile on device; others download prebuilt upstream binaries. Stable fixed-version downloads use pinned SHA-256 hashes, but git clones, mutable URLs, `pip`/`gem` installs, and upstream installers are not hash-pinned. A checksum reduces download-tampering risk, not the risk of a malicious package.

The repository database and packages are GPG-signed; the `[termuxvoid]` entry requires package signatures (`SigLevel = Required DatabaseOptional`). `install-repo.sh` imports and locally signs the TermuxVoid key.

Some packages are dual-use security tools. Use them only on devices, accounts, and networks you own or are explicitly authorized to test. See [SECURITY.md](SECURITY.md) for the disclosure policy.

## FAQ

- **Is this repository safe?** No package is guaranteed safe. Read the package script and upstream source, and test unfamiliar tools in isolation.
- **Is it legal to use these tools?** Only for authorized security research and testing. Unauthorized access or interception is illegal.
- **How often are packages updated?** As upstream releases are verified and issues are handled; there is no fixed schedule. Security-relevant fixes are prioritized.
- **Can I request a new tool?** Yes. Open an issue or ask on [Telegram](https://t.me/termuxvoid).
- **Does this replace the official Termux repositories?** No. It is an additional source for tools that are not available upstream.
- **Can I use this on a normal `pkg`/APT Termux install?** No. Use the [APT repository](https://github.com/termuxvoid/repo) instead.

## Troubleshooting

- **`pacman` not found.** This repository requires a full Pacman bootstrap or `termux-penv`; the standard `pkg` setup uses APT and should install from the [APT repository](https://github.com/termuxvoid/repo).
- **`pacman -S` cannot find a package.** Run `pacman -Syu` first, then confirm the exact package name in the [catalog](assets/PACKAGES.md).
- **A build or download fails.** Refresh the system (`pacman -Syu`), free some storage, and retry. If it still fails, open an issue with the package name and the full error output.
- **Signature or key errors.** Re-run the install command to re-import and locally sign the TermuxVoid key.
- **`command not found` after installation.** Open a new Termux session. Most tools are symlinked into `$PREFIX/bin`, which is on `PATH` by default.

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

- **Tool requests and bug reports:** [GitHub Issues](https://github.com/TermuxVoid/pacman-repo/issues).
- **Package changes:** keep the PKGBUILD in this repository and the matching APT definition in [repo](https://github.com/termuxvoid/repo) in sync.
- **Security reports:** follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Support

- Website: [termuxvoid.github.io](https://termuxvoid.github.io/)
- Telegram: [@termuxvoid](https://t.me/termuxvoid)
- GitHub: [TermuxVoid/pacman-repo](https://github.com/TermuxVoid/pacman-repo)
- YouTube: [@alienkrishnorg](https://youtube.com/@alienkrishnorg)

## License

Released under the [BSD 3-Clause License](LICENSE). TermuxVoid is not affiliated with the Termux project or its maintainers.

<div align="center">
  <sub>Independent third-party project by <a href="https://github.com/Anon4You">Alienkrishn</a>. Review package scripts before installing.</sub>
</div>
