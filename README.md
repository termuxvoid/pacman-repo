<div align="center">
  <a href="https://termuxvoid.github.io/">
    <img alt="TermuxVoid" height="170" src="img/termuxvoid_logo.png">
    <h1>TermuxVoid Pacman Repository</h1>
  </a>
  <p><b>Unofficial Pacman repository: 250+ security and utility tools for Termux</b></p>

  <div>
    <a href="https://github.com/TermuxVoid/pacman-repo/stargazers">
      <img src="https://img.shields.io/github/stars/TermuxVoid/pacman-repo?style=for-the-badge&logo=github&color=ffd700&labelColor=0d1117" alt="GitHub Stars">
    </a>
    <a href="https://github.com/TermuxVoid/pacman-repo/blob/main/LICENSE">
      <img src="https://img.shields.io/badge/License-BSD_3--Clause-blue?style=for-the-badge&logo=opensourceinitiative" alt="License">
    </a>
    <a href="https://github.com/TermuxVoid/pacman-repo/issues">
      <img src="https://img.shields.io/github/issues/TermuxVoid/pacman-repo?style=for-the-badge&logo=github&color=orange&labelColor=0d1117" alt="GitHub Issues">
    </a>
  </div>
</div>

**TermuxVoid** is an unofficial Pacman repository for Termux, packaging **250+ security, Android, AI, and utility tools**. Packages are defined in this repository; some compile on device, while others download upstream releases. Read the package script before installing.

Requires Termux (F-Droid or GitHub), Android 7+, and free storage for large tools.

## Contents

- [Install](#install)
- [Packages](#packages)
  - [Featured Tools](#featured-tools)
  - [AI Tools](#ai-tools)
- [Security](#security)
- [FAQ](#faq)
- [Support](#support)

## Install

```bash
curl -sL https://github.com/termuxvoid/pacman-repo/raw/main/install-repo.sh | bash
```

> [!WARNING]
> Piping a remote script to `bash` runs it immediately. Download and read `install-repo.sh` first if you want to inspect it.

Then install packages:

```bash
# Refresh package lists and upgrade installed packages
pacman -Syu

# Install any tool
pacman -S <tool-name>

# Example
pacman -S metasploit-framework
```

The installer also sets up **tvpkg** (`tvp`), the TermuxVoid package manager.

To remove the repository later:

```bash
curl -sL https://github.com/termuxvoid/pacman-repo/raw/main/uninstall-repo.sh | bash
```

This removes the repository source and key, not packages you already installed.

Using **APT/dpkg**? The same 250+ packages are available from [repo](https://github.com/termuxvoid/repo):

```bash
curl -sL https://github.com/termuxvoid/repo/raw/main/install.sh | bash
```

## Packages

<div align="center">
  <a href="assets/PACKAGES.md">
    <img src="https://img.shields.io/badge/Browse_All_250%2B_Tools-2ea44f?style=for-the-badge" alt="Browse All Tools">
  </a>
</div>

### Featured Tools

| Tool | Category | Description |
| :--- | :--- | :--- |
| **Metasploit** | `Security & Exploitation` | Penetration testing framework. |
| **Burp Suite** | `Web Security` | Web application security testing platform. |
| **Ghidra** | `Security & Exploitation` | Software reverse-engineering suite. |
| **Hydra** | `Networking` | Parallelized login cracker. |
| **SQLMap** | `Web Security` | SQL injection detection and exploitation. |
| **John the Ripper** | `Password Tools` | Password cracker. |

### AI Tools

AI tools may require accounts or API keys and may send data to third-party providers. AI output can be wrong; review generated code before running it.

| Tool | Description |
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

## Security

This is an unofficial, independently maintained project. Package scripts run with your permissions: read the script before installing. Some packages compile on device; others download prebuilt upstream binaries. Stable fixed-version downloads use pinned SHA-256 hashes, but git clones, mutable URLs, `pip`/`gem` installs, and upstream installers are not hash-pinned. A checksum reduces download-tampering risk, not the risk of a malicious package.

The repository database and packages are GPG-signed (`mkrepo.sh SIGN=1`); `install-repo.sh` requires package signatures via `SigLevel = Required DatabaseOptional`.

Some packages are dual-use security tools. Use them only on devices, accounts, and networks you own or are explicitly authorized to test. See [SECURITY.md](SECURITY.md).

## FAQ

- **Is it safe?** No package is guaranteed safe. Read the script and upstream source; test unfamiliar tools in isolation.
- **Is it legal?** Only for authorized security research and testing. Unauthorized access or interception is illegal.
- **How do I update or search?** Run `pacman -Syu`, then `pacman -Ss <tool-name>`.
- **Package missing?** Run `pacman -Syu` and check the [full catalog](assets/PACKAGES.md) for the exact name.
- **How do I uninstall the repository?** Run `curl -sL https://github.com/termuxvoid/pacman-repo/raw/main/uninstall-repo.sh | bash`. This removes the repository source and key, not installed packages.
- **How often updated?** As upstream releases and issues are handled; no fixed schedule.

## Support

[Telegram](https://telegram.me/nullxvoid) · [GitHub](https://github.com/TermuxVoid/pacman-repo) · [YouTube](https://youtube.com/@alienkrishnorg)

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a PR. Report bugs via [Issues](https://github.com/TermuxVoid/pacman-repo/issues).

<div align="center">
  <sub>Unofficial project by <a href="https://github.com/Anon4You">Alienkrishn</a>. Review package scripts before installing.</sub>
</div>
