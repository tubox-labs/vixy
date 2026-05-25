#!/usr/bin/env bash
set -euo pipefail

BINARY="${VIXY_BINARY:-vixy}"
INSTALL_DIR="${VIXY_INSTALL_DIR:-${HOME}/.local/bin}"
RELEASE_API_BASE_URL="${VIXY_RELEASE_API_BASE_URL:-https://veyra.tubox.cloud/vixy}"
DOWNLOAD_BASE_URL="${VIXY_DOWNLOAD_BASE_URL:-https://github.com/tubox-labs/vixy/releases/download}"
VERSION="${VIXY_VERSION:-}"
TMP_DIR=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
warn() { printf "%b%s%b\n" "$YELLOW" "$1" "$NC"; }
error() { printf "%b%s%b\n" "$RED" "$1" "$NC" >&2; exit 1; }

cleanup_tmp_dir() {
    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup_tmp_dir EXIT

usage() {
    cat <<EOF
Usage: $0 [install|upgrade|uninstall]

Environment:
  VIXY_VERSION             Version to install. Defaults to latest allowed release.
  VIXY_RELEASE_API_BASE_URL Version metadata host. Defaults to ${RELEASE_API_BASE_URL}
  VIXY_DOWNLOAD_BASE_URL   Release download host. Defaults to ${DOWNLOAD_BASE_URL}
  VIXY_INSTALL_DIR         Install directory. Defaults to ${INSTALL_DIR}

Release layout:
  ${RELEASE_API_BASE_URL}/releases/latest/VERSION
  ${DOWNLOAD_BASE_URL}/v0.1.0-beta.3/vixy_<os>_<arch>.tar.gz
  ${DOWNLOAD_BASE_URL}/v0.1.0-beta.3/checksums.txt
EOF
}

normalize_version() {
    local version="$1"
    version="${version#v}"
    if ! printf "%s" "$version" | LC_ALL=C grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z][0-9A-Za-z.-]*)?$'; then
        error "Invalid Vixy version: $1"
    fi
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
    local latest_url="${RELEASE_API_BASE_URL%/}/releases/latest/VERSION"
    curl -fsSL "$latest_url" | tr -d '[:space:]' | sed 's/^v//'
}

download_asset() {
    local version="$1"
    local asset="$2"
    local dest="$3"
    local url="${DOWNLOAD_BASE_URL%/}/v${version}/${asset}"

    curl -fsSL "$url" -o "$dest" || error "Download failed: $url"
}

verify_checksum_if_available() {
    local version="$1"
    local asset="$2"
    local archive="$3"
    local checksums="$4"
    local checksum_url="${DOWNLOAD_BASE_URL%/}/v${version}/checksums.txt"

    if ! curl -fsSL "$checksum_url" -o "$checksums"; then
        warn "No checksums.txt found; skipping checksum verification"
        return
    fi

    local expected
    expected=$(awk -v asset="$asset" '{name=$2; sub(/^\*/, "", name); if (name == asset) {print $1}}' "$checksums")
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
        VERSION=$(normalize_version "$(fetch_latest_version)")
    else
        VERSION=$(normalize_version "$VERSION")
    fi
    [ -n "$VERSION" ] || error "Failed to resolve version"

    if command -v "$BINARY" >/dev/null 2>&1; then
        CURRENT_RAW=$("$BINARY" version 2>/dev/null | awk 'NR == 1 {print $3}' || true)
        CURRENT=""
        if [ -n "$CURRENT_RAW" ]; then
            CURRENT="$(normalize_version "$CURRENT_RAW" 2>/dev/null || true)"
        fi
        if [ "$CURRENT" = "$VERSION" ]; then
            info "vixy v${VERSION} is already installed"
            return
        fi
        info "Upgrading vixy from v${CURRENT:-unknown} to v${VERSION}..."
    else
        info "Installing vixy v${VERSION} for ${OS}/${ARCH}..."
    fi

    local asset="vixy_${OS}_${ARCH}.tar.gz"
    TMP_DIR=$(mktemp -d)

    download_asset "$VERSION" "$asset" "$TMP_DIR/$asset"
    verify_checksum_if_available "$VERSION" "$asset" "$TMP_DIR/$asset" "$TMP_DIR/checksums.txt"

    tar -tzf "$TMP_DIR/$asset" >/dev/null 2>&1 || error "Downloaded asset is not a valid tar.gz archive"
    tar -xzf "$TMP_DIR/$asset" -C "$TMP_DIR" || error "Extract failed"
    [ -f "$TMP_DIR/$BINARY" ] || error "Archive did not contain $BINARY"

    mkdir -p "$INSTALL_DIR"
    mv "$TMP_DIR/$BINARY" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$BINARY"

    if ! printf "%s" "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
        warn "Add $INSTALL_DIR to your PATH:"
        warn "  export PATH=\"$INSTALL_DIR:\$PATH\""
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
