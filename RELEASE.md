# Vixy v0.1.0-beta.3 Release Notes

Codename: Harbor Beacon

## Distribution

Vixy v0.1.0-beta.3 is available as platform-specific binary archives.

Expected artifacts:

- `vixy_darwin_amd64.tar.gz`
- `vixy_darwin_arm64.tar.gz`
- `vixy_linux_amd64.tar.gz`
- `vixy_linux_arm64.tar.gz`
- `vixy_windows_amd64.zip`
- `vixy_windows_arm64.zip`
- `checksums.txt`

## Highlights

- Startup auto-update now detects prerelease upgrades correctly.
- `vixy update` is available for manual update checks and installs.
- Release metadata and artifact downloads can be mirrored separately.
- Windows PowerShell mouse-wheel input scrolls chat instead of navigating prompt history.
- macOS and Linux keep normal terminal text selection by default.
- macOS, Linux, and Windows builds are available for amd64 and arm64.

## Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

Pin a version:

```bash
VIXY_VERSION=0.1.0-beta.3 bash install.sh
```
