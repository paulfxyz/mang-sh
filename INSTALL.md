# 📦 Installation Guide — Yo, Rust!

---

## Option A — One-command install (recommended)

This is the easiest path. Works on macOS and Linux.  
It installs Rust automatically if you don't have it yet.

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

After the install completes:

```bash
# Restart your terminal, or reload your shell config:
source ~/.zshrc   # zsh
# or
source ~/.bashrc  # bash

# Then launch:
yo
```

The installer also sets up `hi` and `hello` as aliases — any of the three words will start yo-rust.

---

## Option B — Manual build from source

**Requirements:** [Rust stable](https://rustup.rs/)

```bash
# 1. Install Rust if you don't have it
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# 2. Clone the repository
git clone https://github.com/paulfxyz/yo-rust
cd yo-rust

# 3. Build the release binary
cargo build --release

# 4. Install the binary
sudo cp target/release/yo /usr/local/bin/yo

# 5. (Optional) add hi/hello aliases
echo "alias hi='yo'" >> ~/.zshrc
echo "alias hello='yo'" >> ~/.zshrc
source ~/.zshrc
```

---

## Option C — Install via Cargo

```bash
cargo install yo-rust
```

> Note: the binary name after `cargo install` is `yo`.

---

## First Launch

On first run, yo-rust will ask for:

1. **Your OpenRouter API key**  
   Get one for free at: [https://openrouter.ai/keys](https://openrouter.ai/keys)

2. **A model selection**  
   Choose from the numbered list or paste any OpenRouter model slug.  
   If you're unsure, press Enter to use the default (`openai/gpt-4o-mini`).

Config is saved to `~/.config/yo-rust/config.json` and never leaves your machine.

---

## Updating

To update to the latest version, simply re-run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

Or, if you built from source:

```bash
cd yo-rust
git pull
cargo build --release
sudo cp target/release/yo /usr/local/bin/yo
```

---

## Uninstalling

```bash
# Remove the binary
sudo rm /usr/local/bin/yo

# Remove the config
rm -rf ~/.config/yo-rust

# Remove aliases from your shell config (optional)
# Open ~/.zshrc or ~/.bashrc and delete the yo-rust aliases block
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `yo: command not found` | Ensure `/usr/local/bin` (or `~/.local/bin`) is in your `$PATH`. Restart your terminal. |
| `OpenRouter returned 401` | Your API key is invalid or expired. Run `yo` and type `!api` to update it. |
| `Build failed: error[E0...` | Make sure you have Rust stable: `rustup update stable` |
| Aliases (`hi`, `hello`) not working | Re-source your shell config: `source ~/.zshrc` |
| Model returns no commands | Try a more powerful model via `!api`. Some free models may refuse shell commands. |

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| macOS (Apple Silicon / Intel) | ✅ Fully supported |
| Linux (x86_64, ARM) | ✅ Fully supported |
| Windows (WSL2) | ✅ Works via WSL2 |
| Windows native | ⚠️ Not tested |
