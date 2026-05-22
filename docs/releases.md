# Release Artifacts

Vixy releases are published as platform-specific binary archives with SHA-256
checksums.

## Artifacts

```text
vixy_darwin_amd64.tar.gz
vixy_darwin_arm64.tar.gz
vixy_linux_amd64.tar.gz
vixy_linux_arm64.tar.gz
vixy_windows_amd64.zip
vixy_windows_arm64.zip
checksums.txt
```

## Archive Contents

macOS and Linux archives contain:

```text
vixy
```

Windows archives contain:

```text
vixy.exe
```

## Checksums

Verify an archive manually:

```bash
shasum -a 256 vixy_darwin_arm64.tar.gz
```

Compare the output with `checksums.txt` from the same release.

## Codenames

Every release has a codename. The first beta release is:

```text
Jolly Roger
```
