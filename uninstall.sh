#!/usr/bin/env bash
# =============================================================================
#  uninstall.sh — Remove yo-rust from your system
#  https://github.com/paulfxyz/yo-rust
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/uninstall.sh | bash
#
#  What it removes:
#    • The `yo` binary (wherever it was installed)
#    • The config directory (~/.config/yo-rust/)  ← asks before deleting
#    • The yo-rust alias block from ~/.zshrc / ~/.bashrc
#
#  What it KEEPS (unless you say otherwise):
#    • Rust itself (rustup) — yo-rust didn't install it exclusively
#    • Any other binaries in your PATH
#
#  Works with:  v1.0.0+
# =============================================================================

set -euo pipefail

SUDO=""

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info()  { echo -e "  ${DIM}$1${RESET}"; }
skip()  { echo -e "  ${DIM}–  $1${RESET}"; }
error() { echo -e "  ${RED}✗${RESET}  $1"; exit 1; }

ask() {
    # ask <question> — returns 0 (yes) or 1 (no)
    echo -en "  ${YELLOW}?${RESET}  $1 ${DIM}[y/N]${RESET} "
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║         Uninstalling  Yo, Rust!          ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${DIM}This will remove yo-rust from your system.${RESET}"
echo ""

# ── Confirm intent ────────────────────────────────────────────────────────────
if ! ask "Are you sure you want to uninstall yo-rust?"; then
    echo ""
    echo -e "  ${DIM}Cancelled. Nothing was removed.${RESET}"
    echo ""
    exit 0
fi
echo ""

# ── 1. Find and remove the binary ─────────────────────────────────────────────
YO_BIN="$(command -v yo 2>/dev/null || true)"

if [[ -n "$YO_BIN" ]]; then
    INSTALL_DIR="$(dirname "$YO_BIN")"

    # Check if we need elevated permissions
    if [[ ! -w "$INSTALL_DIR" ]]; then
        if sudo -n true 2>/dev/null; then
            SUDO="sudo"
        else
            warn "Need elevated permissions to remove $YO_BIN"
            SUDO="sudo"
        fi
    fi

    ${SUDO} rm -f "$YO_BIN"
    ok "Removed binary: $YO_BIN"
else
    # Binary might be in a non-PATH location — check common spots
    for candidate in /usr/local/bin/yo "$HOME/.local/bin/yo" "$HOME/bin/yo"; do
        if [[ -f "$candidate" ]]; then
            if [[ ! -w "$(dirname "$candidate")" ]]; then
                SUDO="sudo"
            fi
            ${SUDO} rm -f "$candidate"
            ok "Removed binary: $candidate"
            YO_BIN="$candidate"
            break
        fi
    done

    if [[ -z "$YO_BIN" ]]; then
        skip "Binary not found in PATH or common locations — may have been removed already."
    fi
fi

# ── 2. Remove config directory ────────────────────────────────────────────────
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/yo-rust"

# macOS uses a different config dir
if [[ "$(uname)" == "Darwin" ]]; then
    MACOS_CONFIG="$HOME/Library/Application Support/yo-rust"
    if [[ -d "$MACOS_CONFIG" ]]; then
        CONFIG_DIR="$MACOS_CONFIG"
    fi
fi

if [[ -d "$CONFIG_DIR" ]]; then
    echo ""
    warn "Config directory found: $CONFIG_DIR"
    info "  This contains your API key and model preference."
    echo ""
    if ask "Delete config directory? (you will need to re-enter your API key if you reinstall)"; then
        rm -rf "$CONFIG_DIR"
        ok "Removed config: $CONFIG_DIR"
    else
        skip "Config kept at: $CONFIG_DIR"
    fi
else
    skip "Config directory not found — nothing to remove."
fi

# ── 3. Remove shell aliases ────────────────────────────────────────────────────
echo ""
SHELL_FILES=()
[[ -f "$HOME/.zshrc"   ]] && SHELL_FILES+=("$HOME/.zshrc")
[[ -f "$HOME/.bashrc"  ]] && SHELL_FILES+=("$HOME/.bashrc")
[[ -f "$HOME/.bash_profile" ]] && SHELL_FILES+=("$HOME/.bash_profile")

ALIASES_REMOVED=0
for RC_FILE in "${SHELL_FILES[@]}"; do
    if grep -q "yo-rust aliases" "$RC_FILE" 2>/dev/null; then
        # Use a temp file to safely edit — avoids partial writes
        TMP_RC="$(mktemp)"
        # Remove the alias block: the comment line + the two alias lines + blank line
        grep -v "yo-rust aliases\|alias hi='yo'\|alias hello='yo'" "$RC_FILE" > "$TMP_RC"
        # Remove any resulting double-blank lines left by the deletion
        # (optional cosmetic cleanup — perl one-liner for portability)
        perl -i -0pe 's/\n{3,}/\n\n/g' "$TMP_RC" 2>/dev/null || true
        mv "$TMP_RC" "$RC_FILE"
        ok "Removed yo-rust aliases from $RC_FILE"
        ALIASES_REMOVED=1
    fi
done

if [[ $ALIASES_REMOVED -eq 0 ]]; then
    skip "No yo-rust aliases found in shell config files."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}  ║           Uninstall complete!            ║${RESET}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${DIM}yo-rust has been removed from your system.${RESET}"
echo -e "  ${DIM}Rust itself was not removed — run ${RESET}${BOLD}rustup self uninstall${RESET}${DIM} if you want that too.${RESET}"
echo ""
echo -e "  ${DIM}To reinstall later:${RESET}"
echo -e "  ${CYAN}curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash${RESET}"
echo ""
