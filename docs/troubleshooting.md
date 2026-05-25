# Troubleshooting

## `vixy: command not found`

The installer puts the binary in `~/.local/bin` by default. Add it to `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Download Failed

Check that the release host is reachable:

```bash
curl -fsSL https://veyra.tubox.cloud/vixy/releases/latest/VERSION
```

If you use a mirror, set:

```bash
VIXY_RELEASE_API_BASE_URL=https://your-host.example/vixy
VIXY_DOWNLOAD_BASE_URL=https://your-host.example/vixy
```

## Checksum Mismatch

Do not run the downloaded binary. Remove the archive and retry. If the mismatch
continues, open an issue with:

- Version
- OS and architecture
- Artifact name
- Expected checksum
- Actual checksum

## Unsupported OS Or Architecture

The beta release supports macOS, Linux, and Windows on `amd64` and `arm64`.

## Windows Chat Does Not Scroll

Windows builds enable TUI mouse reporting by default so mouse-wheel input
scrolls chat instead of navigating prompt history. If you need to force native
terminal mouse behavior, start Vixy with `VIXY_MOUSE=0`.

## Need Version Metadata

Run:

```bash
vixy version
```
