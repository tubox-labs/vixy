# Installation

## Quick Install

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

The installer downloads the latest platform archive, verifies it against
`checksums.txt` when available, and places `vixy` in `~/.local/bin` by default.

## Pin A Version

```bash
VIXY_VERSION=0.1.0-beta.2 bash install.sh
```

## Custom Install Directory

```bash
VIXY_INSTALL_DIR=/usr/local/bin bash install.sh
```

## Custom Release Host

```bash
VIXY_DOWNLOAD_BASE_URL=https://example.com/vixy bash install.sh
```

The custom host must expose the same release layout documented in
[releases.md](releases.md).

## Upgrade

Run the installer again:

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/install.sh | bash -s uninstall
```
