# Configuration

Vixy stores user-level configuration under:

```text
~/.vixy/
```

Project-level configuration can live under:

```text
<project>/.vixy/
```

Common environment variables:

| Variable | Purpose |
| --- | --- |
| `VIXY_VERSION` | Pin a version during install. |
| `VIXY_INSTALL_DIR` | Choose install directory. |
| `VIXY_DOWNLOAD_BASE_URL` | Override the release host. |
| `VIXY_AUTO_UPDATE=0` | Disable startup update checks. |
| `VIXY_DEBUG=1` | Enable debug logging. |

Run `/model` inside Vixy to configure model providers. Do not put API keys in
public issues or pull requests.
