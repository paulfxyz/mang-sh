# Installation Guide -- Yo, Rust!

> **Quick reference**
> ```bash
> # Install
> curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
>
> # Update
> curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.sh | bash
>
> # Uninstall
> curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/uninstall.sh | bash
> ```

---

## Install

### Option A -- One-command install (recommended)

Works on **macOS and Linux**. Installs Rust automatically if you don't have it.

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

After it completes, reload your shell:

```bash
source ~/.zshrc    # zsh
source ~/.bashrc   # bash
```

Then:

```
yo
```

The installer also registers `hi` and `hello` as aliases -- any of the three words launches yo-rust.
Safe to re-run at any time: replaces the binary in-place, your config is never touched.

---

### Option B -- Manual build from source

Requirements: **[Rust stable](https://rustup.rs/)**

```bash
# 1. Install Rust (skip if you already have it)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# 2. Clone and build
git clone https://github.com/paulfxyz/yo-rust
cd yo-rust
cargo build --release

# 3. Install
sudo cp target/release/yo /usr/local/bin/yo

# 4. Aliases (optional)
echo "alias hi='yo'"    >> ~/.zshrc
echo "alias hello='yo'" >> ~/.zshrc
source ~/.zshrc
```

---

### Option C -- Cargo install

```bash
cargo install yo-rust
```

The installed binary will be named `yo`.

---

## First launch

On first run yo-rust asks for two things:

1. **OpenRouter API key** -- get yours at [openrouter.ai/keys](https://openrouter.ai/keys)
2. **Model** -- press Enter for the default (`openai/gpt-4o-mini`), or pick from the numbered list

Config is saved to `~/.config/yo-rust/config.json`
(macOS: `~/Library/Application Support/yo-rust/config.json`) and never leaves your machine.

---

## Update

### One-command update

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.sh | bash
```

The update script:
- Reads your installed version from the binary
- Fetches the latest version from GitHub
- **Exits early** with no build if you're already up to date
- Replaces the binary at its existing install location
- Never touches your config or shell aliases

### Manual update

```bash
# Re-running yo.sh has the same effect as update.sh
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

Or from a local clone:

```bash
cd yo-rust
git pull
cargo build --release
sudo cp target/release/yo /usr/local/bin/yo
```

---

## Uninstall

### One-command uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/uninstall.sh | bash
```

The script will:
1. Ask for confirmation before doing anything (`[Y/N]`)
2. Find and remove the `yo` binary (checks PATH and common locations)
3. Ask before removing your config -- **kept by default** so reinstalling is seamless
4. Remove the `hi` / `hello` alias block from `~/.zshrc` and `~/.bashrc`

> **Note on piped execution:** All prompts read from `/dev/tty` directly, so the
> `[Y/N]` questions work correctly even when the script is run via `curl | bash`.

### Manual uninstall

```bash
# 1. Remove the binary
sudo rm -f /usr/local/bin/yo
# If installed to the user-local fallback:
rm -f ~/.local/bin/yo

# 2. Remove config (optional -- contains your API key)
rm -rf ~/.config/yo-rust
# macOS:
rm -rf ~/Library/Application\ Support/yo-rust

# 3. Remove aliases
#    Open ~/.zshrc or ~/.bashrc and delete:
#      # yo-rust aliases -- added by yo.sh
#      alias hi='yo'
#      alias hello='yo'
```

To also remove Rust (if you installed it only for yo-rust):

```bash
rustup self uninstall
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `yo: command not found` after install | Run `source ~/.zshrc` (or `~/.bashrc`). If still missing, check that the install dir is in `$PATH`: `echo $PATH`. |
| `OpenRouter returned 401` | Your API key is invalid or expired. Type `!api` inside yo-rust to update it. |
| `Build failed: error[E0...` | Rust toolchain may be outdated: `rustup update stable` |
| `hi` / `hello` not working | Run `source ~/.zshrc` to reload aliases. |
| Model returns no commands | Switch models with `!api`. Free-tier models can hit rate limits or refuse structured JSON output. |
| Stuck on "Thinking..." for > 30 s | Check your connection. Switch to `gpt-4o-mini` with `!api` -- it is the most reliable model for this use case. |
| Config in unexpected location | macOS: `~/Library/Application Support/yo-rust/`. Linux: `~/.config/yo-rust/`. |
| Uninstall prompt accepts nothing | The script reads from `/dev/tty`. Make sure you're in an interactive terminal, not inside another pipe. |

---

## Supported platforms

| Platform | Status |
|---|---|
| macOS -- Apple Silicon (arm64) | Fully supported |
| macOS -- Intel (x86_64) | Fully supported |
| Linux -- x86_64 | Fully supported |
| Linux -- ARM / Raspberry Pi | Fully supported |
| Windows -- WSL2 | Works |
| Windows -- native CMD / PowerShell | Untested |
