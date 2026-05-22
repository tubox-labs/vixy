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

The first beta release supports macOS and Linux on `amd64` and `arm64`.

## Need Version Metadata

Run:

```bash
vixy version
```
