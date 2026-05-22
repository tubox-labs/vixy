# Vixy v0.1.0-beta.1 Release Notes

Codename: Jolly Roger

## Distribution

Vixy v0.1.0-beta.1 is available as platform-specific binary archives.

Expected artifacts:

- `vixy_darwin_amd64.tar.gz`
- `vixy_darwin_arm64.tar.gz`
- `vixy_linux_amd64.tar.gz`
- `vixy_linux_arm64.tar.gz`
- `vixy_windows_amd64.zip`
- `vixy_windows_arm64.zip`
- `checksums.txt`

## Highlights

- First beta release of the Vixy CLI.
- Native terminal text selection works in the TUI.
- ANSI color fragments no longer leak into rendered chat text.
- The message box shows `Agent is working. Press Esc to interrupt...` while a response is active.
- Release binaries print version, commit, build date, and codename metadata.
- macOS, Linux, and Windows builds are available for amd64 and arm64.

## Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

Pin a version:

```bash
VIXY_VERSION=0.1.0-beta.1 bash install.sh
```
