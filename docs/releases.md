# Release Artifacts

Vixy releases are binary-only. The public repository tracks metadata and
checksums, not source code.

## Host Layout

```text
releases/latest/VERSION
releases/v0.1.0-beta.1/vixy_darwin_amd64.tar.gz
releases/v0.1.0-beta.1/vixy_darwin_arm64.tar.gz
releases/v0.1.0-beta.1/vixy_linux_amd64.tar.gz
releases/v0.1.0-beta.1/vixy_linux_arm64.tar.gz
releases/v0.1.0-beta.1/checksums.txt
install.sh
```

`releases/latest/VERSION` contains the latest version without a leading `v`:

```text
0.1.0-beta.1
```

## Archive Contents

Each archive contains a single executable:

```text
vixy
```

## Checksums

Verify an archive manually:

```bash
shasum -a 256 vixy_darwin_arm64.tar.gz
```

Compare the output with `releases/v0.1.0-beta.1/checksums.txt`.

## Codenames

Every public release has a codename. The first beta release is:

```text
Jolly Roger
```
