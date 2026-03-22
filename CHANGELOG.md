# 📝 Changelog — Yo, Rust!

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.1.3] — 2026-03-22

### 🐛 Fixed

- **Critical: uninstall.sh prompt was always treated as "No"** when run via
  `curl | bash`. Root cause: `read -r reply` was reading from the pipe (the
  script content) rather than the terminal, getting an empty string immediately,
  which never matched `^[Yy]$`. Fix: all interactive prompts now read from
  `/dev/tty` directly (`read -r reply </dev/tty`), which is the actual terminal
  regardless of how stdin is connected.
- **Prompt label corrected** -- confirmation prompts now show `[Y/N]` (both
  uppercase) as the primary confirm, or `[y/N]` (uppercase N = default no)
  for destructive optional steps like config deletion. Previous code showed
  `[y/N]` for the main confirmation, making it look like No was the default.
- **Unicode encoding issues removed** -- all three scripts were written with
  Unicode box-drawing and arrow characters (`─`, `▶`, `✔`, etc.) embedded in
  bash `echo` statements. These can corrupt on some terminals and editors.
  All scripts now use pure ASCII (`+`, `-`, `|`, `[ok]`, `[!!]`) for maximum
  portability.
- **`printf` replaces `echo -e`** throughout all scripts -- `echo -e` behaviour
  is not guaranteed across shells (undefined in POSIX). `printf` is portable.
- **`trap` added** to `yo.sh` and `update.sh` -- temp directory is now cleaned
  up on any exit (success or failure), preventing leftover build directories.
- **Version detection improved** in `update.sh` -- added `|| true` guard so
  the script never exits with an error if `strings` or `grep` finds nothing.
- **INSTALL.md rewritten** -- added `/dev/tty` note under uninstall, added
  troubleshooting row for the prompt issue, cleaned all markdown.

### ✨ New (carried from v1.1.2)


- **`update.sh`** — dedicated update script (`curl -fsSL .../update.sh | bash`).
  Detects installed version, fetches latest from GitHub, skips if already current,
  replaces binary in-place. Config and aliases are never modified.
- **`uninstall.sh`** — clean full-removal script. Finds the binary wherever it was
  installed, asks before deleting config (preserves API key by default), removes
  the `hi`/`hello` alias block from `~/.zshrc` and `~/.bashrc` using a safe
  temp-file edit. Prints reinstall command at the end.
- **`yo.sh` improved** — now detects an existing install and shows the current
  version before building. Replaces binary at the original install location.
  Prints update and uninstall one-liners at the end of every install.
- **`INSTALL.md` rewritten** — single reference for install, update, uninstall,
  manual steps, troubleshooting table, and platform support matrix.
- **README** — update and uninstall one-liners added under the install section;
  `update.sh` and `uninstall.sh` added to the code structure table.

### 🐛 Fix (carried from v1.1.1)

- **Default model changed back to `openai/gpt-4o-mini`** — the free Llama 3.3 70B tier
  hits OpenRouter rate limits quickly under normal usage and does not follow the
  structured JSON schema as reliably as GPT-4o-mini. Since yo-rust is designed for
  users with a paid OpenRouter account, `gpt-4o-mini` is the better default: fast,
  cheap (~$0.15/1M tokens), and consistently produces correct shell commands.
- **Model selection menu reordered** — `gpt-4o-mini` is now option 1 (default),
  followed by `gpt-4o`, `claude-3.5-sonnet`, `claude-3-haiku`, and `llama-3.3-70b-instruct:free`.
  Free Llama moved to position 5 with a note about rate limits.
- **Version bumped** to `1.1.1` across all files: `Cargo.toml`, `src/ui.rs` (`VERSION` const),
  `README.md` (badge + two ASCII banner blocks + changelog heading), `CHANGELOG.md`.

---

## [1.1.0] — 2026-03-22

### 📚 Documentation & Code Quality

- **Deep source annotations** across all four modules (`main.rs`, `ai.rs`, `config.rs`, `ui.rs`)
  — every function, type, and design decision is now documented with the *why*, not just the *what*.
  Comments explain tradeoffs (blocking vs async, `sh -c` vs direct exec, regex vs LLM intent),
  performance characteristics, and future improvement paths.
- **`Cargo.toml` fully annotated** — every dependency includes a comment explaining what it does,
  why it was chosen over alternatives, and which features are enabled and why.

### 🎨 UI & UX

- **VERSION const** introduced in `ui.rs` — the banner version string is now a single source of
  truth. Changing the version only requires updating `Cargo.toml` and `VERSION` in `ui.rs`.
- **Help screen expanded** — shows macOS and Linux config paths separately, documents ↑/↓ history
  navigation, adds 2 new prompt examples (watch log, count code lines).
- **Suggestion box** minimum width increased (46 chars) and right-padding improved for better
  visual alignment across commands of varying length.

### 🧠 AI & Prompting

- **System prompt tightened** — Rule 4 now explicitly says "POSIX sh-compatible" and
  "avoid bash-isms" to reduce shell-specific syntax that breaks on `/bin/sh`.
- **Default model changed** to `meta-llama/llama-3.3-70b-instruct:free` — free-tier, no credit
  card required, excellent quality for shell command generation.
- **Model selection menu reordered** — free tier listed first to reduce friction for new users.

### 🔒 Security & Config

- **Security notes added** to `config.rs` documenting the plaintext storage tradeoff and the
  future keychain integration path.
- **Config path comment** explains the fallback chain (`dirs::config_dir()` → `"."`) and why
  atomic writes are not used for this file size.

---

## [1.0.0] — 2026-03-22

### 🌟 Initial Release

- 🚀 **Core REPL loop** — interactive terminal session launched by `yo`, `hi`, or `hello`
- 🤖 **ASCII banner** — split-panel robot illustration + block-letter YO, RUST! logo on every launch
- 🔑 **First-run setup** — prompts for OpenRouter API key and model on first launch; never asks again
- 🧠 **Natural language → shell commands** — structured JSON envelope prompt forces reliable,
  parseable output from any OpenRouter model
- ✅ **Y/N confirmation** — no command runs without explicit user approval; bare Enter = Y
- 💬 **AI explanation** — every suggestion includes a one-sentence plain-English description
- 🔁 **Intent detection** — 8 regex patterns detect "change my API key / switch model" phrases
  before any API call, triggering reconfiguration instantly
- ⌨️ **Shortcuts** — `!help` / `!h`, `!api`, `!exit` / `!q`, `Ctrl+D`
- 🌍 **Context injection** — OS, arch, CWD, and shell sent with every request for accurate,
  platform-appropriate command suggestions
- 🛡️ **Temperature 0.2** — deterministic, conservative outputs; tested across GPT-4o-mini,
  Claude 3 Haiku, and Llama 3.3 70B
- 🐚 **Shell aliases** — `hi` and `hello` added to `.zshrc` / `.bashrc` by the installer
- 📦 **One-command installer** (`yo.sh`) — auto-installs Rust via rustup, clones, builds
  release binary, installs to `/usr/local/bin/yo` or `~/.local/bin/yo`
- 📜 **In-session history** — rustyline provides ↑/↓ recall of previous prompts
- 📚 **Documentation** — `README.md`, `INSTALL.md`, `CHANGELOG.md`, MIT `LICENSE`

---

*Future releases will be tracked here.*
