#!/usr/bin/env bash
# =============================================================================
#  yo.sh — Install (or reinstall) yo-rust
#  https://github.com/paulfxyz/yo-rust
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
#
#  What it does:
#    1. Detects whether yo is already installed and shows the current version
#    2. Checks for Rust/Cargo — installs via rustup automatically if missing
#    3. Clones the repo (shallow clone for speed) and builds a release binary
#    4. Installs the binary as `yo` in /usr/local/bin (or ~/.local/bin)
#    5. Adds `hi` and `hello` as shell aliases (skips if already present)
#
#  This script is safe to re-run — it updates an existing install in-place.
#  Your config (~/.config/yo-rust/config.json) is never touched.
#
#  To UPDATE only:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.sh | bash
#
#  To UNINSTALL:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/uninstall.sh | bash
# =============================================================================

set -euo pipefail

REPO="https://github.com/paulfxyz/yo-rust"
RAW="https://raw.githubusercontent.com/paulfxyz/yo-rust/main"
BIN_NAME="yo"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR=""
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
echo -e "${CYAN}  ║         Installing  Yo, Rust!            ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── Detect existing install ───────────────────────────────────────────────────
EXISTING_BIN="$(command -v yo 2>/dev/null || true)"
if [[ -n "$EXISTING_BIN" ]]; then
    EXISTING_VERSION="$(strings "$EXISTING_BIN" 2>/dev/null \
        | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")"
    warn "yo-rust is already installed at $EXISTING_BIN (${EXISTING_VERSION})"
    info "  Reinstalling will replace the binary. Your config is safe."
    echo ""
fi

# ── Fetch latest version for display ─────────────────────────────────────────
LATEST_VERSION="$(curl -fsSL "$RAW/Cargo.toml" 2>/dev/null \
    | grep '^version' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" \
    || LATEST_VERSION="latest"
info "Installing version: ${BOLD}v${LATEST_VERSION}${RESET}"
echo ""

# ── 1. Check / install Rust ───────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env" 2>/dev/null || true
fi

if ! command -v cargo &>/dev/null; then
    warn "Rust not found. Installing via rustup…"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env" 2>/dev/null || true
    if ! command -v cargo &>/dev/null; then
        error "Rust installation failed. Install manually: https://rustup.rs"
    fi
    ok "Rust installed."
else
    ok "Rust: $(rustc --version)"
fi

# ── 2. Clone + build ──────────────────────────────────────────────────────────
log "Cloning yo-rust (shallow)…"
git clone --depth 1 "$REPO" "$TMP_DIR/yo-rust" &>/dev/null

log "Building release binary (~30 s on first build, faster on subsequent runs)…"
(cd "$TMP_DIR/yo-rust" && cargo build --release --quiet 2>&1)

BINARY="$TMP_DIR/yo-rust/target/release/yo"
[[ -f "$BINARY" ]] || error "Build failed — binary not found. Please open an issue at $REPO"
ok "Build complete."

# ── 3. Install the binary ─────────────────────────────────────────────────────
# Priority: existing install location > /usr/local/bin > ~/.local/bin
if [[ -n "$EXISTING_BIN" ]]; then
    # Replace in-place at the same location as the existing install
    INSTALL_DIR="$(dirname "$EXISTING_BIN")"
elif [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    # Try with sudo
    if sudo -n true 2>/dev/null; then
        INSTALL_DIR="/usr/local/bin"
        SUDO="sudo"
    else
        # Fallback: user-local bin (no sudo required)
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
    fi
fi

# Need sudo if the install dir is not writable
if [[ ! -w "$INSTALL_DIR" ]]; then
    SUDO="sudo"
fi

${SUDO} cp "$BINARY" "$INSTALL_DIR/$BIN_NAME"
${SUDO} chmod +x "$INSTALL_DIR/$BIN_NAME"
ok "Installed → $INSTALL_DIR/$BIN_NAME"

# ── 4. Shell aliases: hi / hello ─────────────────────────────────────────────
SHELL_RC=""
if [[ "$SHELL" == */zsh ]];  then SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    if ! grep -q "yo-rust aliases" "$SHELL_RC" 2>/dev/null; then
        printf '\n# yo-rust aliases — added by yo.sh installer\nalias hi='"'"'yo'"'"'\nalias hello='"'"'yo'"'"'\n' >> "$SHELL_RC"
        ok "Aliases added to $SHELL_RC  (hi / hello → yo)"
    else
        ok "Aliases already present in $SHELL_RC"
    fi
fi

# ── 5. Cleanup ────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║           Installation complete!         ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""
if [[ -n "$SHELL_RC" ]]; then
    echo -e "  Reload your shell:  ${BOLD}source $SHELL_RC${RESET}"
    echo ""
fi
echo -e "  Then type  ${CYAN}${BOLD}yo${RESET}  to start."
echo ""
echo -e "  ${DIM}Update later:${RESET}    curl -fsSL $RAW/update.sh | bash"
echo -e "  ${DIM}Uninstall:${RESET}       curl -fsSL $RAW/uninstall.sh | bash"
echo ""
