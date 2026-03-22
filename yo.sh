#!/usr/bin/env bash
# =============================================================================
#  yo.sh — One-command installer for yo-rust
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
#
#  What it does:
#    1. Checks for Rust / Cargo (installs via rustup if missing)
#    2. Clones the repo and builds the binary with `cargo build --release`
#    3. Installs the binary as `yo` in /usr/local/bin (or ~/bin as fallback)
#    4. Creates shell aliases so `hi` and `hello` also work
# =============================================================================

set -euo pipefail

REPO="https://github.com/paulfxyz/yo-rust"
BIN_NAME="yo"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR=""

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log()    { echo -e "  ${CYAN}◌${RESET}  $1"; }
ok()     { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn()   { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
error()  { echo -e "  ${RED}✗${RESET}  $1"; exit 1; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║         Installing  Yo, Rust!            ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Check / install Rust ───────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    warn "Rust not found. Installing via rustup…"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
    # Source the new cargo env within this script
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env" 2>/dev/null || true
    if ! command -v cargo &>/dev/null; then
        error "Rust installation failed. Please install manually: https://rustup.rs"
    fi
    ok "Rust installed."
else
    ok "Rust already installed: $(rustc --version)"
fi

# ── 2. Clone + build ──────────────────────────────────────────────────────────
log "Cloning yo-rust…"
git clone --depth 1 "$REPO" "$TMP_DIR/yo-rust" &>/dev/null

log "Building release binary (this takes ~30 seconds on first build)…"
(cd "$TMP_DIR/yo-rust" && cargo build --release --quiet 2>&1)

BINARY="$TMP_DIR/yo-rust/target/release/yo"
if [[ ! -f "$BINARY" ]]; then
    error "Build failed — binary not found at expected path."
fi
ok "Build successful."

# ── 3. Install the binary ─────────────────────────────────────────────────────
if [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
elif sudo -n true 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
    SUDO="sudo"
else
    # Fallback: user's local bin directory (created if needed)
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

${SUDO:-} cp "$BINARY" "$INSTALL_DIR/$BIN_NAME"
${SUDO:-} chmod +x "$INSTALL_DIR/$BIN_NAME"
ok "Installed binary → $INSTALL_DIR/$BIN_NAME"

# ── 4. Add shell aliases: hi / hello ─────────────────────────────────────────
SHELL_RC=""
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    ALIAS_BLOCK="
# yo-rust aliases — added by yo.sh installer
alias hi='yo'
alias hello='yo'
"
    # Only add if not already present
    if ! grep -q "yo-rust aliases" "$SHELL_RC" 2>/dev/null; then
        echo "$ALIAS_BLOCK" >> "$SHELL_RC"
        ok "Aliases added to $SHELL_RC (hi, hello → yo)"
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
echo -e "  ${BOLD}Restart your terminal (or run: source $SHELL_RC)${RESET}"
echo ""
echo -e "  Then just type  ${CYAN}${BOLD}yo${RESET}  to start."
echo ""
