# Vixy v0.1.0-beta.2 Release Notes

Codename: Signal Lantern

## Distribution

Vixy v0.1.0-beta.2 is available as platform-specific binary archives.

Expected artifacts:

- `vixy_darwin_amd64.tar.gz`
- `vixy_darwin_arm64.tar.gz`
- `vixy_linux_amd64.tar.gz`
- `vixy_linux_arm64.tar.gz`
- `vixy_windows_amd64.zip`
- `vixy_windows_arm64.zip`
- `checksums.txt`

## Highlights

- Veyra free-plan requests now avoid oversized context and output-token defaults.
- API keys without quota/access read permission fall back to free-safe request limits.
- Native terminal text selection works in interactive mode by default.
- Mouse reporting is still available as an opt-in with `VIXY_MOUSE=1`.
- Shell and PowerShell installers are available.
- macOS, Linux, and Windows builds are available for amd64 and arm64.

## Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

Pin a version:

```bash
VIXY_VERSION=0.1.0-beta.2 bash install.sh
```
