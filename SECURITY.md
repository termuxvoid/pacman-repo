# Security Policy

## Scope

This policy covers TermuxVoid Pacman packaging and install scripts. Report vulnerabilities in upstream tools to their maintainers.

## Before Installing

Package definitions and lifecycle scripts are public: read the script before installing. Some packages compile on device; others download prebuilt upstream binaries. Stable fixed-version downloads use pinned SHA-256 hashes, but git clones, mutable URLs, `pip`/`gem` installs, and upstream installers are not hash-pinned. A checksum verifies download integrity, not package safety.

The repository database and packages are signed (`mkrepo.sh SIGN=1`); `install-repo.sh` imports and trusts the key and sets `SigLevel = Required DatabaseOptional`, which requires package signatures.

Some packages are dual-use security tools. Use them only on devices, accounts, and networks you own or are explicitly authorized to test.

## Report a Security Issue

For sensitive reports, contact [@nullxvoid](https://telegram.me/nullxvoid) on Telegram instead of opening a public issue. Otherwise use [GitHub Issues](https://github.com/TermuxVoid/pacman-repo/issues). No response time is guaranteed.

## Legal

These tools are for educational, research, and authorized security testing only. You are responsible for complying with applicable laws, platform terms, and authorization requirements. The maintainer accepts no liability for misuse, damage, or data loss.
