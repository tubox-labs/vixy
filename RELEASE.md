# Vixy v0.1.0-beta.1 Release Notes

Codename: Jolly Roger

## Distribution

Vixy is distributed as private binary artifacts from:

```text
https://veyra.tubox.cloud/vixy/releases/v0.1.0-beta.1/
```

Expected artifacts:

- `vixy_darwin_amd64.tar.gz`
- `vixy_darwin_arm64.tar.gz`
- `vixy_linux_amd64.tar.gz`
- `vixy_linux_arm64.tar.gz`
- `checksums.txt`

The latest pointer contains only the version number:

```text
https://veyra.tubox.cloud/vixy/releases/latest/VERSION
```

## Highlights

- First beta public distribution metadata for the private Vixy CLI.
- Native terminal text selection works in the TUI.
- ANSI color fragments no longer leak into rendered chat text.
- The message box shows `Agent is working. Press Esc to interrupt...` while a response is active.
- Release binaries print version, commit, build date, and codename metadata.

## Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

Pin a version:

```bash
VIXY_VERSION=0.1.0-beta.1 bash install.sh
```
