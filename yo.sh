#!/usr/bin/env bash
# =============================================================================
#  yo.sh -- Install or reinstall yo-rust
#  https://github.com/paulfxyz/yo-rust
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
#
#  Or run directly after download:
#    bash yo.sh
#
#  What this script does:
#    1. Detects if yo is already installed and shows the current version
#    2. Checks for Rust/Cargo -- installs via rustup automatically if missing
#    3. Clones the repo (shallow, fast) and builds a release binary
#    4. Installs the binary as `yo` -- at the same location if reinstalling
#    5. Adds `hi` and `hello` as shell aliases (skips if already present)
#
#  Safe to re-run: replaces the binary in-place. Config is never modified.
#
#  Related scripts:
#    update.sh    -- update to latest (skips if already current)
#    uninstall.sh -- full removal with prompts
# =============================================================================

set -euo pipefail

REPO="https://github.com/paulfxyz/yo-rust"
RAW="https://raw.githubusercontent.com/paulfxyz/yo-rust/main"
BIN_NAME="yo"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR=""
SUDO=""

# -- Colours ------------------------------------------------------------------
RED='\033[0;31m'
GRN='\033[0;32m'
CYN='\033[0;36m'
YLW='\033[1;33m'
BLD='\033[1m'
DIM='\033[2m'
RST='\033[0m'

log()  { printf "  ${CYN}[..]${RST}  %s\n" "$1"; }
ok()   { printf "  ${GRN}[ok]${RST}  %s\n" "$1"; }
warn() { printf "  ${YLW}[!!]${RST}  %s\n" "$1"; }
info() { printf "  ${DIM}      %s${RST}\n"  "$1"; }
die()  { printf "  ${RED}[!!]${RST}  %s\n" "$1"; rm -rf "$TMP_DIR"; exit 1; }

# Cleanup temp dir on any exit (success or failure)
trap 'rm -rf "$TMP_DIR"' EXIT

# -- Banner -------------------------------------------------------------------
printf "\n"
printf "${CYN}  +==========================================+${RST}\n"
printf "${CYN}  |        Installing  Yo, Rust!            |${RST}\n"
printf "${CYN}  +==========================================+${RST}\n"
printf "\n"

# =============================================================================
#  Step 1 -- Detect existing install
# =============================================================================
EXISTING_BIN="$(command -v yo 2>/dev/null || true)"

if [[ -n "$EXISTING_BIN" ]]; then
    # Extract version embedded in the binary (see ui.rs VERSION const)
    EXISTING_VERSION="$(strings "$EXISTING_BIN" 2>/dev/null \
        | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' \
        | head -1 || echo "unknown")"
    warn "yo is already installed at $EXISTING_BIN (${EXISTING_VERSION})"
    info "Reinstalling will replace the binary. Your config is not affected."
    printf "\n"
fi

# Show the version we are about to install
LATEST_VERSION="$(curl -fsSL --max-time 10 "$RAW/Cargo.toml" 2>/dev/null \
    | grep '^version' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    || echo "")"
if [[ -n "$LATEST_VERSION" ]]; then
    info "Target version: ${BLD}v${LATEST_VERSION}${RST}"
    printf "\n"
fi

# =============================================================================
#  Step 2 -- Check / install Rust
# =============================================================================
# Source cargo env in case it was installed in a previous step this session
# shellcheck disable=SC1090
source "$HOME/.cargo/env" 2>/dev/null || true

if ! command -v cargo &>/dev/null; then
    warn "Rust not found -- installing via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env" 2>/dev/null || true
    command -v cargo &>/dev/null || die "Rust installation failed. Install manually: https://rustup.rs"
    ok "Rust installed."
else
    ok "Rust: $(rustc --version)"
fi

# =============================================================================
#  Step 3 -- Clone and build
# =============================================================================
log "Cloning yo-rust (latest, shallow)..."
git clone --depth 1 "$REPO" "$TMP_DIR/yo-rust" &>/dev/null

log "Building release binary (first build ~30 s, reinstalls are faster)..."
(cd "$TMP_DIR/yo-rust" && cargo build --release --quiet 2>&1)

BINARY="$TMP_DIR/yo-rust/target/release/yo"
[[ -f "$BINARY" ]] || die "Build failed -- binary not found. Please open an issue at $REPO/issues"
ok "Build complete."

# =============================================================================
#  Step 4 -- Install binary
# =============================================================================
if [[ -n "$EXISTING_BIN" ]]; then
    # Reinstall: put it back where it already lives
    INSTALL_DIR="$(dirname "$EXISTING_BIN")"
elif [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
elif sudo -n true 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
    SUDO="sudo"
else
    # Fallback: user-local bin (no sudo required)
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

# Re-check write permission for the resolved dir (covers the reinstall path)
if [[ ! -w "$INSTALL_DIR" ]]; then
    if sudo -n true 2>/dev/null; then
        SUDO="sudo"
    else
        warn "Need elevated permissions to write to $INSTALL_DIR."
        warn "You may be prompted for your password."
        SUDO="sudo"
    fi
fi

${SUDO} cp "$BINARY" "$INSTALL_DIR/$BIN_NAME"
${SUDO} chmod +x "$INSTALL_DIR/$BIN_NAME"
ok "Installed: $INSTALL_DIR/$BIN_NAME"

# =============================================================================
#  Step 5 -- Shell aliases: hi / hello
# =============================================================================
SHELL_RC=""
case "$SHELL" in
    */zsh)  SHELL_RC="$HOME/.zshrc"   ;;
    */bash) SHELL_RC="$HOME/.bashrc"  ;;
esac

if [[ -n "$SHELL_RC" ]]; then
    if ! grep -q "yo-rust aliases" "$SHELL_RC" 2>/dev/null; then
        printf "\n# yo-rust aliases -- added by yo.sh\nalias hi='yo'\nalias hello='yo'\n" >> "$SHELL_RC"
        ok "Aliases added to $SHELL_RC  (hi / hello -> yo)"
    else
        ok "Aliases already present in $SHELL_RC"
    fi
fi

# =============================================================================
#  Done
# =============================================================================
printf "\n"
printf "${CYN}  +==========================================+${RST}\n"
printf "${CYN}  |        Installation complete!           |${RST}\n"
printf "${CYN}  +==========================================+${RST}\n"
printf "\n"
if [[ -n "$SHELL_RC" ]]; then
    printf "  Reload your shell config:\n"
    printf "  ${BLD}  source %s${RST}\n" "$SHELL_RC"
    printf "\n"
fi
printf "  Then type  ${CYN}${BLD}yo${RST}  to start.\n"
printf "\n"
printf "  ${DIM}Update:    curl -fsSL $RAW/update.sh    | bash${RST}\n"
printf "  ${DIM}Uninstall: curl -fsSL $RAW/uninstall.sh | bash${RST}\n"
printf "\n"
