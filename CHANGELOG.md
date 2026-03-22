# 📝 Changelog — Yo, Rust!

All notable changes to this project will be documented in this file.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.0.0] — 2026-03-22

### 🌟 Initial Release

- 🚀 **Core REPL loop** — interactive terminal session launched by `yo`, `hi`, or `hello`
- 🤖 **ASCII banner** — robot illustration with "YO, RUST!" logo on every launch
- 🔑 **First-run setup** — prompts for OpenRouter API key and model selection on first launch
- 🧠 **Natural language → shell commands** — sends prompts to OpenRouter and returns structured JSON with command suggestions
- ✅ **Y/N confirmation** — no command runs without explicit user approval
- 💬 **AI explanation** — each suggestion includes a one-sentence description of what the commands do
- 🔁 **Intent detection** — phrases like "change my API key" or "switch model" trigger reconfiguration automatically
- ⌨️ **Shortcuts:**
  - `!help` / `!h` — display the help screen
  - `!api` — update API key and model
  - `!exit` / `!q` — quit
  - `Ctrl+D` — exit at any time
- 🗂️ **Config persistence** — settings stored at `~/.config/yo-rust/config.json`
- 🌍 **Context injection** — current OS, arch, CWD, and shell are sent with each request for accurate command suggestions
- 🛡️ **Low-temperature prompting** — `temperature: 0.2` for deterministic and safer outputs
- 📦 **One-command installer** — `yo.sh` installs Rust + builds + installs binary automatically
- 🔗 **Shell aliases** — `hi` and `hello` added to `.zshrc` / `.bashrc` by the installer
- 📚 **Documentation** — `README.md`, `INSTALL.md`, `CHANGELOG.md`
- 📜 MIT License

---

*Future releases will be tracked here.*
