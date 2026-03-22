# 🤖 Yo, Rust!

**Natural language → Terminal commands, powered by AI.**

> Just type `yo` — and talk to your terminal like a human.

---

## 👨‍💻 The Story Behind This

I got tired of Googling syntax for commands I half-remember and half-forget.  
I wanted something stupid-simple: open a terminal, type `yo`, describe what I want to do, and just have it work.

No Python dependency hell. No Node.js version drama. Just a single compiled binary, a free OpenRouter API key, and you're off.  
Built in Rust, zero bloat, fast as hell.

---

## 🌟 What is this?

**yo-rust** is an open-source terminal assistant. You describe what you want to do in plain English and it suggests the shell commands to do it. You confirm with `Y` or refine with `N` — nothing runs without your approval.

**Key features:**

- 🗣️ Natural language → shell commands via any OpenRouter model
- ✅ Always asks for confirmation before running anything
- ⚡ Single compiled binary — no runtime, no dependencies
- 🔑 API key stored locally in `~/.config/yo-rust/config.json`
- 🎨 Fancy ASCII welcome screen
- 🧠 Detects intent (e.g. *"change my API key"* triggers reconfiguration)
- 📟 Built-in shortcuts: `!help`, `!api`, `!exit`
- 🐚 Aliases: `hi` and `hello` both launch yo-rust
- 🛡️ Low-temperature prompting for safer, deterministic command suggestions

---

## 🚀 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

That's it. Rust will be installed automatically if missing.  
After installation, restart your terminal and type:

```
yo
```

---

## 🎬 How it works

```
$ yo

  ╔═══════════════════════════════════════════════════╗
  ║    ██╗   ██╗ ██████╗     ██████╗ ██╗   ██╗       ║
  ║    ╚██╗ ██╔╝██╔═══██╗    ██╔══██╗██║   ██║       ║
  ║     ╚████╔╝ ██║   ██║    ██████╔╝██║   ██║       ║
  ║      ╚██╔╝  ██║   ██║    ██╔══██╗██║   ██║       ║
  ║       ██║   ╚██████╔╝    ██║  ██║╚██████╔╝       ║
  ║       ╚═╝    ╚═════╝     ╚═╝  ╚═╝ ╚═════╝        ║
  ╚═══════════════════════════════════════════════════╝

  yo ›  show me the 10 biggest files in this folder

  ◈  Lists files sorted by size, showing the 10 largest.

  ┌─────────────────────────────────────────────────┐
  │    $  du -ah . | sort -rh | head -n 10          │
  └─────────────────────────────────────────────────┘

  Run it? [Y/n] › Y

  ►  du -ah . | sort -rh | head -n 10
  ...output...
  ✔  Done.
```

1. **First launch** — yo-rust asks for your [OpenRouter API key](https://openrouter.ai/keys) and preferred model.
2. **Type a request** — describe what you want in plain English.
3. **Review** — yo-rust shows the suggested command(s) with a brief explanation.
4. **Confirm** — press `Y` to run or `N` to refine.

---

## ⌨️ Shortcuts

| Command     | What it does                              |
|-------------|-------------------------------------------|
| `!help`     | Show the help screen                      |
| `!api`      | Update your OpenRouter API key and model  |
| `!exit`     | Quit yo-rust                              |
| `Ctrl+D`    | Exit at any time                          |

Natural language also works for reconfiguration — try:  
> *"change my API key"* or *"switch to a different model"*

---

## 🛠️ Manual Build (from source)

Requirements: [Rust](https://rustup.rs/) (stable)

```bash
git clone https://github.com/paulfxyz/yo-rust
cd yo-rust
cargo build --release
sudo cp target/release/yo /usr/local/bin/yo
```

---

## 🧠 How it works under the hood

**Prompt engineering:**  
yo-rust sends a structured system prompt that instructs the model to reply exclusively with a JSON object:
```json
{
  "commands": ["cmd1", "cmd2"],
  "explanation": "One sentence describing what these commands do."
}
```
This makes parsing reliable and avoids markdown noise or prose around the commands.

**Temperature:**  
Set to `0.2` — low enough for deterministic, safe command suggestions, high enough to handle natural language variation.

**Context injection:**  
Each prompt is prefixed with system context (`OS`, `ARCH`, `CWD`, `SHELL`) so the model can tailor commands to your actual environment.

**Intent detection:**  
A lightweight regex layer (`ai.rs`) detects phrases like *"change my api key"* or *"switch model"* before the request ever hits the API, making reconfiguration feel natural.

**Config persistence:**  
Config lives at `~/.config/yo-rust/config.json`. It's a plain JSON file — you can edit it manually if needed.

---

## 🔑 OpenRouter

yo-rust uses [OpenRouter](https://openrouter.ai) as its AI provider.  
OpenRouter is an API aggregator — one key gives you access to GPT-4o, Claude, Llama, and many others, including **free-tier models**.

Get your key at: [https://openrouter.ai/keys](https://openrouter.ai/keys)

Recommended free model: `meta-llama/llama-3.3-70b-instruct:free`

---

## 📁 What's in the box

| File / Folder          | Purpose                                      |
|------------------------|----------------------------------------------|
| `src/main.rs`          | Entry point, REPL loop, command execution    |
| `src/ai.rs`            | OpenRouter API integration, intent detection |
| `src/config.rs`        | Config load/save, interactive setup          |
| `src/ui.rs`            | Banner, help text, suggestion display        |
| `Cargo.toml`           | Rust project manifest & dependencies         |
| `yo.sh`                | One-command installer                        |
| `README.md`            | You're reading it                            |
| `INSTALL.md`           | Detailed installation guide                  |
| `CHANGELOG.md`         | Version history                              |

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feat/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push: `git push origin feat/amazing-feature`
5. Open a Pull Request

Feature ideas welcome:
- Shell history integration (append executed commands to `~/.zsh_history`)
- Multi-step command pipelines with explanations per step
- Dry-run mode (`--dry` flag)
- Offline mode with a local Ollama backend

---

## 📝 Changelog

> Full history: **[CHANGELOG.md](CHANGELOG.md)**

---

## 📜 License

MIT — see [LICENSE](LICENSE)

---

## 👤 Author

**Paul Fleury**  
Website: [paulfleury.com](https://paulfleury.com) · LinkedIn: [paulfxyz](https://www.linkedin.com/in/paulfxyz/) · GitHub: [@paulfxyz](https://github.com/paulfxyz)

Built with [Perplexity Computer](https://www.perplexity.ai).  
If you find this useful, drop a ⭐ — it helps a lot.
