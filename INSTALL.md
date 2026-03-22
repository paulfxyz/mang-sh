# 📦 Installation Guide — Yo, Rust!

---

## Install

### Option A — One-command install ✨ recommended

Works on **macOS and Linux**. Installs Rust automatically if you don't have it.

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

After it completes, reload your shell:

```bash
source ~/.zshrc    # zsh
source ~/.bashrc   # bash
```

Then just type:

```
yo
```

The installer also registers `hi` and `hello` as aliases — any of the three words launches yo-rust.  
Safe to re-run — replaces the binary in-place, your config is never touched.

---

### Option B — Manual build from source

Requirements: **[Rust stable](https://rustup.rs/)**

```bash
# 1. Install Rust (skip if you already have it)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# 2. Clone
git clone https://github.com/paulfxyz/yo-rust
cd yo-rust

# 3. Build the release binary
cargo build --release

# 4. Install
sudo cp target/release/yo /usr/local/bin/yo

# 5. Add aliases (optional)
echo "alias hi='yo'"    >> ~/.zshrc
echo "alias hello='yo'" >> ~/.zshrc
source ~/.zshrc
```

---

### Option C — Cargo install

```bash
cargo install yo-rust
```

The installed binary will be named `yo`.

---

## First launch

On first run yo-rust will ask for two things:

1. **Your OpenRouter API key** — get one at [openrouter.ai/keys](https://openrouter.ai/keys)
2. **A model** — press Enter for the default (`openai/gpt-4o-mini`), or pick from the list

Config is saved to `~/.config/yo-rust/config.json` (macOS: `~/Library/Application Support/yo-rust/config.json`) and never leaves your machine.

---

## Update

### One-command update

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.sh | bash
```

This script:
- Detects your current installed version
- Checks the latest version on GitHub
- Exits early if you're already up to date
- Builds and replaces the binary in-place
- **Never touches your config or aliases**

### Manual update

```bash
# Re-run the installer (same effect)
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
- Remove the `yo` binary (wherever it was installed)
- Ask before deleting your config directory (API key + model preference)
- Remove the `hi` / `hello` alias block from `~/.zshrc` or `~/.bashrc`
- Leave Rust itself installed (you may use it for other things)

### Manual uninstall

```bash
# 1. Remove the binary
sudo rm -f /usr/local/bin/yo
# or, if installed to the user-local fallback:
rm -f ~/.local/bin/yo

# 2. Remove the config (optional — contains your API key)
rm -rf ~/.config/yo-rust
# macOS:
rm -rf ~/Library/Application\ Support/yo-rust

# 3. Remove aliases from your shell config
#    Open ~/.zshrc or ~/.bashrc and delete the block that looks like:
#      # yo-rust aliases — added by yo.sh installer
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
| `yo: command not found` after install | Run `source ~/.zshrc` (or `~/.bashrc`). If still missing, check that `/usr/local/bin` or `~/.local/bin` is in your `$PATH`. |
| `OpenRouter returned 401` | Your API key is invalid or expired. Type `!api` inside yo-rust to update it. |
| `Build failed: error[E0…` | Your Rust toolchain may be outdated: `rustup update stable` |
| `hi` / `hello` aliases not working | Run `source ~/.zshrc` to reload your shell config. |
| Model returns no commands | Try a different model with `!api`. Free-tier models may hit rate limits or refuse structured output. |
| Stuck on "Thinking…" for > 30 s | Check your internet connection. The free Llama tier can be slow under load — switch to `gpt-4o-mini` with `!api`. |
| Config in unexpected location | macOS stores it in `~/Library/Application Support/yo-rust/`. Linux uses `~/.config/yo-rust/`. |

---

## Supported platforms

| Platform | Status |
|---|---|
| macOS — Apple Silicon (arm64) | ✅ Fully supported |
| macOS — Intel (x86_64) | ✅ Fully supported |
| Linux — x86_64 | ✅ Fully supported |
| Linux — ARM / Raspberry Pi | ✅ Fully supported |
| Windows — WSL2 | ✅ Works |
| Windows — native CMD / PowerShell | ⚠️ Untested |
