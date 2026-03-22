# 🤖 Yo, Rust!

<div align="center">

**Natural language → Terminal commands, powered by AI.**

*Just type `yo` — and talk to your terminal like a human.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Built with Rust](https://img.shields.io/badge/Built%20with-Rust-orange?style=for-the-badge&logo=rust)](https://www.rust-lang.org/)
[![Powered by OpenRouter](https://img.shields.io/badge/Powered%20by-OpenRouter-6c47ff?style=for-the-badge)](https://openrouter.ai)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue?style=for-the-badge)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](https://github.com/paulfxyz/yo-rust/pulls)

</div>

---

```
  ██╗   ██╗ ██████╗       ██████╗ ██╗   ██╗███████╗████████╗
  ╚██╗ ██╔╝██╔═══██╗      ██╔══██╗██║   ██║██╔════╝╚══██╔══╝
   ╚████╔╝ ██║   ██║      ██████╔╝██║   ██║███████╗   ██║
    ╚██╔╝  ██║   ██║      ██╔══██╗██║   ██║╚════██║   ██║
     ██║   ╚██████╔╝      ██║  ██║╚██████╔╝███████║   ██║
     ╚═╝    ╚═════╝       ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝

         ┌──────────────────────────────────────┐
         │  ╔══════╗   yo, rust!   ╔══════╗    │
         │  ║ ◉  ◉ ║               ║ ◉  ◉ ║    │
         │  ╚══════╝               ╚══════╝    │
         │          ┌────────────┐             │
         │          │ ◌   ◌   ◌  │             │
         │          └────────────┘             │
         └──────────────────────────────────────┘
              /\                        /\
             /  \______________________/  \
```

---

## 👨‍💻 The Story Behind This

I'm **Paul Fleury** — French internet entrepreneur based in Lisbon, managing infrastructure, DNS, deployments, and all the usual sysadmin chaos across multiple projects.

At some point I started noticing a pattern: I'd lose 10 minutes Googling command syntax I half-remember. `find` flags. `awk` one-liners. `openssl` commands. `rsync` options. Not hard things — just things you don't type every day and always forget the exact flags for.

I wanted something that felt like texting a friend who knows Linux. Open terminal. Type `yo`. Say what I want. Get the command. Run it. Done.

Python? Node? Not interested in dependency hell. I wanted a **single compiled binary** that just works — fast, clean, no runtime.

So I built it in **Rust**, powered by **[OpenRouter](https://openrouter.ai)** (one key, every model, including free tiers), with a simple `curl | bash` installer that handles everything — even Rust itself if you don't have it.

> 💡 This project was designed and built in collaboration with **[Perplexity Computer](https://www.perplexity.ai)** — from architecture through implementation. A genuine example of human intent + AI execution.

---

## 🌟 What is this?

**yo-rust** is an open-source terminal assistant. Describe what you want to do in plain English — it suggests the shell commands to do it. You confirm with `Y` or refine with `N`. Nothing ever runs without your approval.

**Key features:**

- 🗣️ **Natural language → shell commands** via any OpenRouter-supported model (GPT-4o, Claude, Llama, Mixtral…)
- ✅ **Always asks for confirmation** — no command runs without explicit `Y`
- ⚡ **Single compiled binary** — no Python, no Node.js, no runtime dependencies
- 🔑 **API key stored locally** — `~/.config/yo-rust/config.json`, never leaves your machine
- 🎨 **Fancy ASCII welcome screen** — robot illustration on every launch
- 🧠 **Intent detection** — say *"change my API key"* and it just knows
- 📟 **Built-in shortcuts** — `!help`, `!api`, `!exit`
- 🐚 **Three aliases** — `yo`, `hi`, or `hello` all launch it
- 🌍 **Context-aware** — sends OS, arch, CWD, and shell to the model for accurate suggestions
- 🛡️ **Low-temperature prompting** — `0.2` temperature for safe, deterministic outputs
- 💬 **Explanations included** — every suggestion comes with a one-sentence description

---

## 🚀 Quick Install

One command. Works on macOS and Linux. Installs Rust automatically if you don't have it.

```bash
curl -fsSL https://raw.githubusercontent.com/paulfxyz/yo-rust/main/yo.sh | bash
```

Then restart your terminal and type:

```
yo
```

That's it. On first launch, you'll be asked for your [OpenRouter API key](https://openrouter.ai/keys) and preferred model. Takes 30 seconds.

---

## 🎬 See it in action

```
$ yo

  ██╗   ██╗ ██████╗       ██████╗ ██╗   ██╗███████╗████████╗
  ╚██╗ ██╔╝██╔═══██╗      ██╔══██╗██║   ██║██╔════╝╚══██╔══╝
   ╚████╔╝ ██║   ██║      ██████╔╝██║   ██║███████╗   ██║
    ╚██╔╝  ██║   ██║      ██╔══██╗██║   ██║╚════██║   ██║
     ██║   ╚██████╔╝      ██║  ██║╚██████╔╝███████║   ██║
     ╚═╝    ╚═════╝       ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝

         ┌──────────────────────────────────────┐
         │  ╔══════╗   yo, rust!   ╔══════╗    │
         │  ║ ◉  ◉ ║               ║ ◉  ◉ ║    │
         │  ╚══════╝               ╚══════╝    │
         │          ┌────────────┐             │
         │          │ ◌   ◌   ◌  │             │
         │          └────────────┘             │
         └──────────────────────────────────────┘
              /\                        /\
             /  \______________________/  \

  Natural language → Terminal commands, powered by AI.
  Type !help for options.

  yo ›  find all .env files in this directory tree

  ◈  Searches recursively for files named .env, showing their paths.

  ┌─────────────────────────────────────────────────────┐
  │    $  find . -name ".env" -type f                   │
  └─────────────────────────────────────────────────────┘

  Run it? [Y/n] › Y

  ►  find . -name ".env" -type f
  ./projects/api/.env
  ./projects/web/.env
  ✔  Done.
```

**More examples:**

```
yo ›  show the 10 biggest files in this folder
  ◈  Lists files and directories sorted by size, largest first.
  $ du -ah . | sort -rh | head -n 10

yo ›  kill the process running on port 3000
  ◈  Finds the PID of the process on port 3000 and terminates it.
  $ lsof -ti:3000 | xargs kill -9

yo ›  compress the videos folder into a tar.gz
  ◈  Creates a gzip-compressed tar archive of the videos directory.
  $ tar -czf videos.tar.gz videos/

yo ›  show git commits from the last 7 days with author names
  ◈  Displays a log of commits from the past week, including author and date.
  $ git log --since="7 days ago" --pretty=format:"%h %an %ad %s" --date=short

yo ›  check which ports are currently open and listening
  ◈  Lists all TCP/UDP ports currently in the LISTEN state.
  $ ss -tlnp
```

---

## ⌨️ Shortcuts & Commands

| Input | What happens |
|---|---|
| `!help` / `!h` | Show the full help screen |
| `!api` | Change your OpenRouter API key and/or model |
| `!exit` / `!q` | Quit yo-rust |
| `Ctrl+D` | Exit at any time |
| `Y` or Enter | Run the suggested command(s) |
| `N` | Skip — refine your prompt and try again |

Natural language also works for configuration:

```
yo ›  change my API key           → triggers !api
yo ›  switch to a different model → triggers !api
yo ›  update my openrouter key    → triggers !api
```

---

## 🔑 OpenRouter — One Key, Every Model

yo-rust uses **[OpenRouter](https://openrouter.ai)** as its AI backbone. OpenRouter is a single-API aggregator that gives you access to GPT-4o, Claude 3.5 Sonnet, Llama 3.3, Mistral, Gemini, and dozens more — including several **free-tier models**.

Get your key in 60 seconds: **[openrouter.ai/keys](https://openrouter.ai/keys)**

### Recommended models

| Model | Why use it |
|---|---|
| `meta-llama/llama-3.3-70b-instruct:free` | 🆓 Free tier — great for most tasks |
| `openai/gpt-4o-mini` | Fast, cheap, very good at shell commands |
| `openai/gpt-4o` | More powerful, handles complex multi-step requests |
| `anthropic/claude-3.5-sonnet` | Best reasoning for intricate pipelines |
| `anthropic/claude-3-haiku` | Extremely fast, low cost |

You can use **any model slug** from the [OpenRouter model list](https://openrouter.ai/models) — paste it directly during setup.

---

## 🛠️ Manual Build (from source)

Requirements: **[Rust stable](https://rustup.rs/)**

```bash
# 1. Install Rust (if needed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# 2. Clone
git clone https://github.com/paulfxyz/yo-rust
cd yo-rust

# 3. Build
cargo build --release

# 4. Install
sudo cp target/release/yo /usr/local/bin/yo

# 5. (Optional) aliases
echo "alias hi='yo'" >> ~/.zshrc
echo "alias hello='yo'" >> ~/.zshrc
source ~/.zshrc
```

---

## 📁 Code Structure

```
yo-rust/
├── src/
│   ├── main.rs        Entry point, REPL loop, command execution
│   ├── ai.rs          OpenRouter API call, JSON parsing, intent detection
│   ├── config.rs      Config load/save, interactive setup wizard
│   └── ui.rs          ASCII banner, help screen, suggestion display
├── Cargo.toml         Rust project manifest & dependencies
├── yo.sh              One-command installer (curl | bash)
├── README.md          You're reading it
├── INSTALL.md         Detailed installation guide
├── CHANGELOG.md       Version history
└── LICENSE            MIT
```

---

## 🧠 How it works under the hood

### Structured prompt engineering

yo-rust sends a tightly-scoped system prompt that forces the model to reply exclusively as a JSON object:

```json
{
  "commands": ["cmd1", "cmd2"],
  "explanation": "One sentence describing what these commands do."
}
```

No markdown, no prose, no fences. This makes parsing deterministic and immune to the model's tendency to wrap output in explanatory text. The envelope is stripped of any accidental markdown fences before parsing — belt-and-suspenders.

### Temperature 0.2 — the sweet spot

Shell commands are not a creative endeavour. A temperature of `0.2` keeps outputs focused and predictable — the model picks the most likely correct command, not an interesting variation. High enough to understand natural language variation, low enough to not hallucinate flags.

### Context injection — commands that match your machine

Every request is prefixed with a short context string:

```
System context: OS=macos ARCH=aarch64 CWD=/Users/paul/projects/api SHELL=/bin/zsh
User request: show all docker containers including stopped ones
```

This means the model knows whether to use `open` vs `xdg-open`, `pbcopy` vs `xclip`, `brew` vs `apt`, and so on. No generic cross-platform hedging in the output.

### Intent detection without an API call

A lightweight regex layer in `ai.rs` intercepts prompts that match patterns like:

```
"change.*api"   "update.*api"   "new.*api.*key"
"switch.*model" "change.*model" "different.*model"
```

If matched, yo-rust triggers the `!api` flow directly — no network call, no latency, feels instant and natural.

### Command execution via `sh -c`

Commands are executed via `std::process::Command::new("sh").arg("-c").arg(cmd)` with inherited stdin/stdout/stderr. This means:
- Interactive commands like `vim`, `htop`, `less` work correctly
- Piped commands like `cat file | grep foo` work as expected
- Output appears in real time — no buffering

### Config stored locally, always

`~/.config/yo-rust/config.json` — plain JSON, editable manually, never sent anywhere except directly to OpenRouter in the `Authorization` header. No telemetry, no analytics, no callbacks.

---

## 🔬 Lessons learned building this

**JSON envelope > freeform output.** Early versions asked the model to "output just the command". It almost always added explanation, markdown, or qualifiers. Forcing a strict JSON schema with a defined `commands` array and `explanation` field solved this completely.

**Low temperature matters more than model choice.** The same model at `temperature: 1.0` will invent flags. At `0.2`, it stays grounded. For command suggestion, you want a confident assistant, not a creative one.

**Context beats capability.** A small model with OS/CWD context outperforms a large model without it. Knowing the user is on macOS ARM means `brew` not `apt`, `open` not `xdg-open`. Simple but makes a real difference.

**Regex intent detection feels more natural than a second API call.** Sending "change my API key" to the AI to figure out what the user wants is slow, costs tokens, and is overkill. A 5-pattern regex takes microseconds and covers 95% of cases.

**Rust's `std::process::Command` with inherited stdio is the right choice.** Capturing stdout and printing it after the fact makes interactive commands break. Inheriting stdio means `vim`, `htop`, and any TUI tools work seamlessly.

---

## 📝 Changelog

> Full history: **[CHANGELOG.md](CHANGELOG.md)**

### 🔖 v1.0.0 — 2026-03-22

- 🚀 Initial release
- 🤖 ASCII robot banner + YO, RUST! logo
- 🧠 OpenRouter API integration with JSON envelope parsing
- ✅ Y/N confirmation before any command executes
- 🔑 First-run interactive setup (API key + model)
- 🌍 Context injection (OS, arch, CWD, shell)
- 🔁 Regex-based intent detection for API key changes
- ⌨️ Shortcuts: `!help`, `!api`, `!exit`
- 🐚 Shell aliases: `hi` and `hello` via installer
- 📦 One-command installer (`yo.sh`) with auto Rust install
- 📚 Full documentation: README, INSTALL, CHANGELOG

---

## 🤝 Contributing

Pull requests are very welcome. Ideas to explore:

- 📜 Shell history integration — append executed commands to `~/.zsh_history`
- 🔁 Multi-step pipelines with per-step explanations
- 🧪 Dry-run mode — show commands without running them
- 🏠 Offline mode via [Ollama](https://ollama.ai) backend
- 🪝 Post-execution feedback — "did that work?" loop
- 🎨 Theme support (colours, minimal mode)

```bash
# Contribution flow
git checkout -b feat/your-feature
git commit -m 'feat: describe your change'
git push origin feat/your-feature
# Open a Pull Request
```

---

## 📜 License

MIT — free to use, modify, and distribute. See [LICENSE](LICENSE) for details.

---

## 👤 Author

Made with ❤️ by **Paul Fleury** — designed and built in collaboration with **[Perplexity Computer](https://www.perplexity.ai)**.

- 🌐 Website: **[paulfleury.com](https://paulfleury.com)**
- 🔗 LinkedIn: **[linkedin.com/in/paulfxyz](https://www.linkedin.com/in/paulfxyz/)**
- 🐦 GitHub: **[@paulfxyz](https://github.com/paulfxyz)**
- 📧 Email: **[hello@paulfleury.com](mailto:hello@paulfleury.com)**

---

<div align="center">

⭐ **If this saved you time, drop a star — it helps others find it!** ⭐

</div>
