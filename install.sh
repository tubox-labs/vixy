#!/usr/bin/env bash
set -euo pipefail

BINARY="${VIXY_BINARY:-vixy}"
INSTALL_DIR="${VIXY_INSTALL_DIR:-${HOME}/.local/bin}"
BASE_URL="${VIXY_DOWNLOAD_BASE_URL:-https://veyra.tubox.cloud/vixy}"
VERSION="${VIXY_VERSION:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
warn() { printf "%b%s%b\n" "$YELLOW" "$1" "$NC"; }
error() { printf "%b%s%b\n" "$RED" "$1" "$NC" >&2; exit 1; }

usage() {
    cat <<EOF
Usage: $0 [install|upgrade|uninstall]

Environment:
  VIXY_VERSION             Version to install. Defaults to latest.
  VIXY_DOWNLOAD_BASE_URL   Release host. Defaults to ${BASE_URL}
  VIXY_INSTALL_DIR         Install directory. Defaults to ${INSTALL_DIR}
  VIXY_BINARY              Binary name. Defaults to ${BINARY}

Release layout:
  ${BASE_URL}/releases/latest/VERSION
  ${BASE_URL}/releases/v0.1.0-beta.1/vixy_<os>_<arch>.tar.gz
  ${BASE_URL}/releases/v0.1.0-beta.1/checksums.txt
EOF
}

normalize_version() {
    local version="$1"
    version="${version#v}"
    printf "%s" "$version"
}

detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac

    case "$OS" in
        darwin|linux) ;;
        *) error "Unsupported OS: $OS" ;;
    esac
}

fetch_latest_version() {
    local latest_url="${BASE_URL%/}/releases/latest/VERSION"
    curl -fsSL "$latest_url" | tr -d '[:space:]' | sed 's/^v//'
}

download_asset() {
    local version="$1"
    local asset="$2"
    local dest="$3"
    local url="${BASE_URL%/}/releases/v${version}/${asset}"

    curl -fsSL "$url" -o "$dest" || error "Download failed: $url"
}

verify_checksum_if_available() {
    local version="$1"
    local asset="$2"
    local archive="$3"
    local checksums="$4"
    local checksum_url="${BASE_URL%/}/releases/v${version}/checksums.txt"

    if ! curl -fsSL "$checksum_url" -o "$checksums"; then
        warn "No checksums.txt found; skipping checksum verification"
        return
    fi

    local expected
    expected=$(awk -v asset="$asset" '$2 == asset {print $1}' "$checksums")
    [ -n "$expected" ] || error "checksums.txt does not contain $asset"

    local actual
    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$archive" | awk '{print $1}')
    else
        actual=$(shasum -a 256 "$archive" | awk '{print $1}')
    fi

    [ "$actual" = "$expected" ] || error "Checksum mismatch for $asset"
}

do_install() {
    detect_platform

    if [ -z "$VERSION" ]; then
        info "Fetching latest Vixy version..."
        VERSION=$(fetch_latest_version)
    else
        VERSION=$(normalize_version "$VERSION")
    fi
    [ -n "$VERSION" ] || error "Failed to resolve version"

    if command -v "$BINARY" >/dev/null 2>&1; then
        CURRENT=$("$BINARY" version 2>/dev/null | awk 'NR == 1 {print $3}' || true)
        CURRENT="$(normalize_version "$CURRENT")"
        if [ "$CURRENT" = "$VERSION" ]; then
            info "vixy v${VERSION} is already installed"
            return
        fi
        info "Upgrading vixy from v${CURRENT:-unknown} to v${VERSION}..."
    else
        info "Installing vixy v${VERSION} for ${OS}/${ARCH}..."
    fi

    local asset="vixy_${OS}_${ARCH}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    download_asset "$VERSION" "$asset" "$tmp_dir/$asset"
    verify_checksum_if_available "$VERSION" "$asset" "$tmp_dir/$asset" "$tmp_dir/checksums.txt"

    tar -tzf "$tmp_dir/$asset" >/dev/null 2>&1 || error "Downloaded asset is not a valid tar.gz archive"
    tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" || error "Extract failed"
    [ -f "$tmp_dir/$BINARY" ] || error "Archive did not contain $BINARY"

    mkdir -p "$INSTALL_DIR"
    mv "$tmp_dir/$BINARY" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$BINARY"

    if ! printf "%s" "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
        warn "Add $INSTALL_DIR to your PATH:"
        warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi

    info "vixy v${VERSION} installed to $INSTALL_DIR/$BINARY"
}

do_uninstall() {
    info "Uninstalling vixy..."

    if [ -f "$INSTALL_DIR/$BINARY" ]; then
        rm "$INSTALL_DIR/$BINARY"
        info "Removed $INSTALL_DIR/$BINARY"
    else
        warn "Binary not found at $INSTALL_DIR/$BINARY"
    fi

    if [ -d "$HOME/.vixy" ]; then
        printf "Remove config directory ~/.vixy? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.vixy"
            info "Removed ~/.vixy"
        fi
    fi

    info "Uninstall complete"
}

case "${1:-install}" in
    install|upgrade) do_install ;;
    uninstall|remove) do_uninstall ;;
    -h|--help|help) usage ;;
    *) error "Unknown command: $1" ;;
esac
