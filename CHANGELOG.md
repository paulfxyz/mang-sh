# 📝 Changelog — mang.sh 句芒

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) · Versioning: [SemVer](https://semver.org/)

---

## [3.0.0] — 2026-03-23

### 🏛️ Rebrand — Yo, Rust! → mang.sh (句芒)

This is a breaking rename, not a breaking code change. All features are identical
to v2.3.5. The binary is still invoked as `yo`. The config directory moves from
`~/.config/yo-rust/` to `~/.config/mang-sh/` (handled automatically by the
`dirs` crate using the new Cargo.toml package name `mang-sh`).

**The name change:**

The project started as *Yo, Rust!* — a developer pun. `yo` is the command you
type. Rust is the language underneath. Put them together: Yo, Rust! A coder
shouting at their toolchain.

It was a fine name for a side project. It was a bad name for a tool that deserves
to be taken seriously.

**Gou Mang (句芒):**

In ancient Chinese mythology, Gou Mang serves as the divine messenger between
the Emperor of Heaven and the mortal world. He carries intent across the boundary
between realms — translating the will of heaven into action on earth.

mang.sh does exactly this. You speak in human language — imprecise, contextual,
full of implicit assumptions. The shell speaks in machine language — exact syntax,
specific flags, precise operators. Gou Mang bridges the gap.

The command stays `yo` — a casual, direct summons. No ceremony. The god comes
when called. That's the right tone for a developer tool.

**What changed:**

- Package renamed `mang-sh` in `Cargo.toml`
- Binary still named `yo` (no change to how you invoke it)
- New homepage: `https://mang.sh`
- Install: `curl -fsSL https://mang.sh/install | bash`
- New banner: Gou Mang's cosmic tree + MANG.SH block-letter logotype
- JSONBin collection renamed to `mang-sh-telemetry`
- `MANGDEBUG=1` replaces `YODEBUG=1` for telemetry debugging
- All installer scripts updated with mang.sh branding and URLs
- README completely rewritten with Gou Mang mythology, deeper engineering
  context, and full lessons learned
- INSTALL.md and CHANGELOG.md completely rewritten
- Zero remaining references to the old name anywhere in the codebase

---

## [2.3.5] — 2026-03-23

### ✨ Background update check on every launch

On launch, a background thread silently fetches `Cargo.toml` from GitHub to
check for a newer version. The thread runs concurrently with the banner —
zero startup latency. If a newer version is found:

```
  ◈  Update available: v2.3.6 — type !update to install
```

Rate-limited to once per 24 hours via `~/.config/mang-sh/last_update_check`.

New shortcuts: `!update` / `!upd` / `!check` — force-checks and offers Y/N
to install. On Y, shells out to the update script and exits for a clean restart.

New module: `src/updater.rs`

### ✨ N on a suggestion = iterative refinement tunnel

Pressing N no longer abandons the session — it opens an inline refinement loop:

```
  Run it? [Y/n] › N

  ◈  Let's refine — what should be different?
  yo ›  use zip instead of tar.gz

  ◌  Thinking…

  [refined suggestion with zip]

  Run it? [Y/n] ›
```

The refinement prompt includes the original request AND the previous suggestion,
so the AI understands exactly what to change. Loop continues until Y or cancel
(blank Enter, `!skip`, Ctrl-D).

---

## [2.3.4] — 2026-03-22

### 🐛 Shell script colour variables fixed

Root cause: colour variables were single-quoted — `CYN='\\033[0;36m'` — storing
a literal backslash-033 instead of an ESC byte. `printf` printed the raw escape
sequence instead of rendering colour.

Fix: ANSI-C quoting — `CYN=$'\033[0;36m'` — stores the actual ESC byte at
assignment time. Applied to all three Unix scripts.

---

## [2.3.3] — 2026-03-22

### 🔍 Code audit — zero clippy warnings

- `telemetry.rs`: Fixed `posted_any` logic bug (debug path consumed response
  body before success check), `is_some_and()` replacing `map_or()`,
  `is_multiple_of()` replacing manual modulo in `is_leap()`
- `main.rs`: Fixed duplicate step numbering, fixed `Err(e)` readline exit path
  not joining telemetry handles
- `ui.rs`: Three `print_literal` clippy warnings resolved

---

## [2.3.2] — 2026-03-22

### 🐛 Telemetry entries not appearing in JSONBin

Three bugs causing empty collection:

1. **Detached thread race**: `submit_background()` now returns `JoinHandle`.
   Main loop stores all handles, joins at every exit point (Ctrl-D, Ctrl-C,
   `!exit`, input error). Without this, process exits before HTTP POST completes.
2. **`YODEBUG=1` mode** added: prints JSON payload and HTTP response to stderr.
3. **Success flag logic**: debug path was consuming the response body before the
   `is_success()` check, so `posted_any` was never set in debug mode.

### ✨ `!feedback test`

Sends a live entry synchronously and shows the result immediately. Useful for
verifying the pipeline before relying on it.

---

## [2.3.1] — 2026-03-22

### ✨ `!feedback` / `!fb` shortcut

Full subcommand UI: `!feedback`, `!feedback setup`, `!feedback on/off`,
`!feedback personal` (with live connectivity test), `!feedback clear`,
`!feedback about`, `!feedback test`.

JSONBin.io collection `mang-sh-telemetry` live and accepting entries.

---

## [2.3.0] — 2026-03-22

### ✨ Community telemetry via JSONBin.io

Opt-in anonymous sharing of prompt/command pairs via JSONBin.io.
Write-only Access Key embedded in binary (Bins Create permission only).
Personal JSONBin support for private command history.

---

## [2.2.0] — 2026-03-22

### 🐛 Windows PS5.1 TerminatingError on `cargo build`

Root cause: `$ErrorActionPreference = "Stop"` + `Set-StrictMode` + `2>&1`
caused `cargo`'s normal stderr progress output to trigger `TerminatingError`.

Fix: removed all three. Let cargo output flow to terminal. Check `$LASTEXITCODE`.

### ✨ Named command shortcuts

`!save <name>` · `!<name>` (instant replay) · `!forget <name>` · `!shortcuts`

---

## [2.1.0] — 2026-03-22

### ✨ Native PowerShell installer

`install.ps1`, `update.ps1`, `uninstall.ps1` — no Git Bash or WSL required.
Fixes the `curl -fsSL ... | bash` failure in Windows PowerShell where `curl`
is an alias for `Invoke-WebRequest`.

---

## [2.0.0] — 2026-03-22 · Major version milestone

- 🏠 **Ollama backend** — local inference, no API key, offline
- 🔁 **Multi-turn context** — follow-up prompts resolve correctly
- 📜 **Shell history** — zsh/bash/fish native format appending
- 🧪 **Dry-run** — `yo --dry` with yellow command box
- 🪝 **Post-execution feedback** — "Did that work?" refinement loop
- 🐚 **Shell detection** — zsh, bash, fish, sh, PS5, PS7, cmd.exe, Git Bash
- 🪟 **Windows** — cmd.exe and PowerShell execution, PS5/PS7 syntax
- 🗂️ `!context` / `!clear` · `--no-history` · `--no-context` flags

---

## [1.1.3] — 2026-03-22

### 🐛 Uninstall script prompt fix

Root cause: `read -r reply` read from the pipe (script content) not the
terminal when run via `curl | bash`. Fix: `read -r reply </dev/tty`.
Also: `echo -e` → `printf`, pure ASCII in shell scripts, `trap` for cleanup.

---

## [1.0.0] — 2026-03-22 · Initial release

- Core REPL via `yo`, `hi`, or `hello`
- OpenRouter API with JSON envelope
- Y/N confirmation, first-run setup, context injection
- Regex intent detection, `!help`, `!api`, `!exit`
- One-command installer with auto Rust install
- MIT License
