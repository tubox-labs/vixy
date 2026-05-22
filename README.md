# Vixy

Private AI coding assistant for the terminal.

This public repository is the distribution and support home for Vixy. It does
not contain Vixy's private source code. The CLI is distributed as checksummed
private binary artifacts from the Veyra release host.

## Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

Pin a version:

```bash
VIXY_VERSION=0.1.0-beta.1 bash install.sh
```

Uninstall:

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash -s uninstall
```

## Supported Platforms

The first beta release publishes:

- macOS arm64
- macOS amd64
- Linux arm64
- Linux amd64

Windows binaries are not published in the first beta release.

## Current Release

- Version: `v0.1.0-beta.1`
- Codename: `Jolly Roger`

Expected binary output:

```text
Vixy CLI v0.1.0-beta.1 (Jolly Roger)
Commit: <commit>
Built: <timestamp>
```

## Usage

```bash
vixy                         # open the interactive TUI
vixy "explain this code"     # start with an initial prompt
cat file.go | vixy -p ""     # non-interactive print mode
vixy --continue              # resume the latest session
vixy --resume                # select a previous session
vixy version                 # print version metadata
```

Run `/model` on first launch to connect a provider. Run `/help` inside the TUI
to see slash commands and keyboard shortcuts.

## What Is In This Repo

- Installer script
- Public release notes and checksums
- Installation and troubleshooting docs
- Security and support policy
- GitHub issue templates

## What Is Not In This Repo

- Vixy source code
- Internal architecture docs
- Private build automation
- Release binaries
- Credentials, provider keys, or customer data

## Documentation

- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Release artifacts](docs/releases.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Public repository policy](docs/public-repo-policy.md)
- [Privacy notes](docs/privacy.md)

## Security

Do not open a public issue for a vulnerability. Follow
[SECURITY.md](SECURITY.md).

## License

Vixy source code and binaries are proprietary. See [LICENSE](LICENSE).
