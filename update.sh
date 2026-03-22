#!/usr/bin/env bash
# =============================================================================
#  update.sh — Update yo-rust to the latest version
#  https://github.com/paulfxyz/yo-rust
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.sh | bash
#
#  What it does:
#    1. Detects where yo is currently installed
#    2. Shows the currently installed version
#    3. Fetches the latest version number from GitHub
#    4. If already up to date, exits early
#    5. Pulls latest source, builds a fresh release binary
#    6. Replaces the existing binary in-place (preserves install location)
#    7. Your config (~/.config/yo-rust/config.json) is never touched
#
#  Works with:  v1.0.0+
#  Safe to run: yes — config and aliases are never modified
# =============================================================================

set -euo pipefail

REPO="https://github.com/paulfxyz/yo-rust"
RAW="https://raw.githubusercontent.com/paulfxyz/yo-rust/main"
TMP_DIR="$(mktemp -d)"
SUDO=""

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

log()   { echo -e "  ${CYAN}◌${RESET}  $1"; }
ok()    { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info()  { echo -e "  ${DIM}$1${RESET}"; }
error() { echo -e "  ${RED}✗${RESET}  $1"; exit 1; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║         Updating  Yo, Rust!              ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Check that yo is installed ────────────────────────────────────────────
YO_BIN="$(command -v yo 2>/dev/null || true)"
if [[ -z "$YO_BIN" ]]; then
    warn "yo is not installed or not in PATH."
    echo ""
    info "Run the installer first:"
    info "  curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash"
    echo ""
    exit 1
fi

INSTALL_DIR="$(dirname "$YO_BIN")"
ok "Found yo at: $YO_BIN"

# ── 2. Detect installed version ───────────────────────────────────────────────
# yo-rust prints the version in its banner; we extract it with grep.
# If the binary is too old to have a version line, we fall back to "unknown".
INSTALLED_VERSION="$("$YO_BIN" --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
if [[ -z "$INSTALLED_VERSION" ]]; then
    # Older binaries don't support --version; try extracting from strings output
    INSTALLED_VERSION="$(strings "$YO_BIN" 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")"
fi
info "Installed version: ${BOLD}${INSTALLED_VERSION}${RESET}"

# ── 3. Fetch latest version from Cargo.toml on main ──────────────────────────
log "Checking latest version on GitHub…"
LATEST_VERSION="$(curl -fsSL "$RAW/Cargo.toml" 2>/dev/null \
    | grep '^version' \
    | head -1 \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" || true

if [[ -z "$LATEST_VERSION" ]]; then
    warn "Could not fetch latest version from GitHub. Check your connection."
    warn "Proceeding with build anyway…"
    LATEST_VERSION="latest"
else
    info "Latest version:    ${BOLD}v${LATEST_VERSION}${RESET}"
fi

# ── 4. Early-exit if already up to date ──────────────────────────────────────
if [[ "$INSTALLED_VERSION" == "v${LATEST_VERSION}" ]]; then
    echo ""
    ok "Already up to date (${INSTALLED_VERSION}). Nothing to do."
    echo ""
    exit 0
fi

echo ""
log "Updating ${INSTALLED_VERSION} → v${LATEST_VERSION}…"
echo ""

# ── 5. Check Rust is available ────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    # Source cargo env in case it was installed in this shell session
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env" 2>/dev/null || true
    if ! command -v cargo &>/dev/null; then
        error "Rust/Cargo not found. Run the installer (yo.sh) which will install Rust automatically."
    fi
fi
info "Using: $(rustc --version)"

# ── 6. Clone latest source and build ─────────────────────────────────────────
log "Cloning latest source…"
git clone --depth 1 "$REPO" "$TMP_DIR/yo-rust" &>/dev/null

log "Building release binary…"
(cd "$TMP_DIR/yo-rust" && cargo build --release --quiet 2>&1)

BINARY="$TMP_DIR/yo-rust/target/release/yo"
if [[ ! -f "$BINARY" ]]; then
    rm -rf "$TMP_DIR"
    error "Build failed — binary not found. Try running yo.sh instead."
fi
ok "Build complete."

# ── 7. Replace the binary in-place ───────────────────────────────────────────
# Determine if we need sudo to write to the install directory
if [[ ! -w "$INSTALL_DIR" ]]; then
    if sudo -n true 2>/dev/null; then
        SUDO="sudo"
    else
        warn "Need elevated permissions to write to $INSTALL_DIR"
        warn "You may be prompted for your password."
        SUDO="sudo"
    fi
fi

${SUDO} cp "$BINARY" "$YO_BIN"
${SUDO} chmod +x "$YO_BIN"
ok "Binary updated → $YO_BIN"

# ── 8. Cleanup ────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║           Update complete!               ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}yo-rust ${CYAN}v${LATEST_VERSION}${RESET}${BOLD} is ready.${RESET}  Type ${CYAN}${BOLD}yo${RESET} to start."
echo -e "  ${DIM}Your config (~/.config/yo-rust/config.json) was not changed.${RESET}"
echo ""
