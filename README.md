# Vixy

Private AI coding assistant for the terminal.

Vixy helps developers explore, edit, test, and ship code from a fast terminal
workflow. It combines a keyboard-first TUI, project-aware context, tool
execution, resumable sessions, provider selection, skills, plugins, MCP servers,
hooks, and background agents in a single native CLI.

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

The first beta release publishes binaries for:

- macOS arm64
- macOS amd64
- Linux arm64
- Linux amd64
- Windows arm64
- Windows amd64

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

## Highlights

- Native terminal app with a compact single-binary install.
- Interactive chat, code editing, shell execution, and file-aware workflows.
- Resumable sessions with conversation history.
- Provider and model switching from the terminal.
- Project personas, skills, plugins, MCP servers, hooks, and background agents.
- Workspace trust and permission controls for tool execution.

## Documentation

- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Release artifacts](docs/releases.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Privacy notes](docs/privacy.md)

## Security

Do not open a public issue for a vulnerability. Follow
[SECURITY.md](SECURITY.md).

## License

See [LICENSE](LICENSE).
