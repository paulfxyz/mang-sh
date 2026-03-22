// =============================================================================
//  ui.rs — Terminal UI: banner, help text, suggestion display
//
//  All visual chrome lives here — nothing about logic, IO, or AI.
//  Colours come from the `colored` crate; no ANSI codes are hardcoded.
// =============================================================================

use crate::ai::Suggestion;
use colored::Colorize;

// ─────────────────────────────────────────────────────────────────────────────
//  Banner — printed on every launch
//
//  Design: block-letter "YO, RUST!" logo above a robot face.
//  Fits comfortably in an 80-column terminal.
// ─────────────────────────────────────────────────────────────────────────────
pub fn print_banner() {
    println!();

    // ── YO, block letters ─────────────────────────────────────────────────────
    let logo_yo = [
        "  ██╗   ██╗ ██████╗       ██████╗ ██╗   ██╗███████╗████████╗",
        "  ╚██╗ ██╔╝██╔═══██╗      ██╔══██╗██║   ██║██╔════╝╚══██╔══╝",
        "   ╚████╔╝ ██║   ██║      ██████╔╝██║   ██║███████╗   ██║   ",
        "    ╚██╔╝  ██║   ██║      ██╔══██╗██║   ██║╚════██║   ██║   ",
        "     ██║   ╚██████╔╝      ██║  ██║╚██████╔╝███████║   ██║   ",
        "     ╚═╝    ╚═════╝       ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝  ",
    ];
    for line in &logo_yo {
        println!("{}", line.cyan().bold());
    }

    println!();

    // ── Robot face ────────────────────────────────────────────────────────────
    let robot = [
        "       ┌──────────────────────────────────────┐",
        "       │  ╔══════╗    yo, rust!   ╔══════╗   │",
        "       │  ║ ◉  ◉ ║               ║ ◉  ◉ ║   │",
        "       │  ╚══════╝               ╚══════╝   │",
        "       │          ┌────────────┐            │",
        "       │          │ ◌   ◌   ◌  │            │",
        "       │          └────────────┘            │",
        "       └──────────────────────────────────────┘",
        "            /\\                        /\\      ",
        "           /  \\______________________/  \\     ",
    ];
    for line in &robot {
        println!("{}", line.cyan());
    }

    println!();

    // ── Tagline ───────────────────────────────────────────────────────────────
    println!(
        "  {}",
        "  Natural language → Terminal commands, powered by AI.".white()
    );
    println!(
        "  {}  {}",
        "  ►".cyan(),
        "Type !help for options.  Type !api to configure OpenRouter.".dimmed()
    );
    println!();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Intro — shown after first-run setup, before the REPL prompt
// ─────────────────────────────────────────────────────────────────────────────
pub fn print_intro() {
    println!();
    println!(
        "  {}  {}",
        "◈".cyan().bold(),
        "Describe what you want to do — I'll suggest the commands.".white()
    );
    println!(
        "  {}  {}",
        "◈".cyan().bold(),
        "Press Y to run, N to refine, Ctrl+D to exit.".dimmed()
    );
    println!();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Help screen — triggered by !help
// ─────────────────────────────────────────────────────────────────────────────
pub fn print_help() {
    println!();
    println!("{}", "  ╔══════════════════════════════════════════════════╗".cyan());
    println!("{}", "  ║               🤖  Yo, Rust! — Help               ║".cyan());
    println!("{}", "  ╚══════════════════════════════════════════════════╝".cyan());
    println!();

    // ── What it is ────────────────────────────────────────────────────────────
    println!("  {}", "WHAT IT DOES".white().bold());
    println!(
        "  {}",
        "  Describe what you want in plain English. yo-rust thinks about".dimmed()
    );
    println!(
        "  {}",
        "  your request, then proposes the shell commands to do it.".dimmed()
    );
    println!(
        "  {}",
        "  You confirm with Y or decline with N — nothing ever runs without".dimmed()
    );
    println!(
        "  {}",
        "  your approval.".dimmed()
    );
    println!();

    // ── Examples ─────────────────────────────────────────────────────────────
    println!("  {}", "EXAMPLES".white().bold());
    let examples = [
        ("find all .log files older than 7 days",           "find . -name \"*.log\" -mtime +7"),
        ("kill the process on port 8080",                    "lsof -ti:8080 | xargs kill -9"),
        ("show disk usage for this folder",                  "du -sh ."),
        ("git log for the last 5 commits with author",       "git log -5 --pretty=format:\"%h %an: %s\""),
        ("compress the images folder",                       "tar -czf images.tar.gz images/"),
        ("show all running docker containers",               "docker ps"),
        ("list files changed in the last 24 hours",         "find . -mtime -1 -type f"),
        ("check my public IP address",                       "curl -s https://ifconfig.me"),
    ];
    for (prompt, cmd) in &examples {
        println!(
            "    {}  {}",
            "yo ›".cyan().bold(),
            prompt.white()
        );
        println!(
            "         {}  {}",
            "$".dimmed(),
            cmd.dimmed()
        );
    }
    println!();

    // ── Shortcuts ─────────────────────────────────────────────────────────────
    println!("  {}", "SHORTCUTS".white().bold());
    let shortcuts = [
        ("!help  / !h",   "Display this help screen"),
        ("!api",          "Update your OpenRouter API key and model"),
        ("!exit  / !q",   "Quit yo-rust"),
        ("Ctrl+D",        "Exit at any time"),
    ];
    for (key, desc) in &shortcuts {
        println!(
            "    {}  {}",
            format!("{:<16}", key).yellow().bold(),
            desc.dimmed()
        );
    }
    println!();

    // ── Confirmation ──────────────────────────────────────────────────────────
    println!("  {}", "CONFIRMATION".white().bold());
    println!(
        "    {}  Accept and run the suggested command(s)",
        "Y / Enter  ".green().bold()
    );
    println!(
        "    {}  Decline — refine your prompt and try again",
        "N          ".red().bold()
    );
    println!();

    // ── Natural language config ───────────────────────────────────────────────
    println!("  {}", "NATURAL LANGUAGE TRIGGERS".white().bold());
    println!(
        "  {}",
        "  These phrases trigger reconfiguration without typing !api:".dimmed()
    );
    let nl_triggers = [
        "change my API key",
        "update my openrouter key",
        "switch to a different model",
        "use a new model",
    ];
    for trigger in &nl_triggers {
        println!("    {}  {}", "›".cyan(), trigger.dimmed());
    }
    println!();

    // ── Config ────────────────────────────────────────────────────────────────
    println!("  {}", "CONFIG".white().bold());
    println!(
        "  {}  {}",
        "  Location:".dimmed(),
        "~/.config/yo-rust/config.json".yellow()
    );
    println!(
        "  {}",
        "  Plain JSON — you can edit it manually if needed.".dimmed()
    );
    println!();

    // ── Footer ────────────────────────────────────────────────────────────────
    println!(
        "  {}  {}",
        "◈".cyan(),
        "github.com/paulfxyz/yo-rust".dimmed()
    );
    println!();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Suggestion display — called after the AI responds
// ─────────────────────────────────────────────────────────────────────────────
pub fn print_suggestion(suggestion: &Suggestion) {
    println!();

    if suggestion.commands.is_empty() {
        println!(
            "  {}  {}",
            "⚠".yellow(),
            "No commands were suggested for this request. Try rephrasing.".yellow()
        );
        println!();
        return;
    }

    // ── Explanation ───────────────────────────────────────────────────────────
    if let Some(ref explanation) = suggestion.explanation {
        println!(
            "  {}  {}",
            "◈".cyan().bold(),
            explanation.white()
        );
        println!();
    }

    // ── Command block ─────────────────────────────────────────────────────────
    // Calculate the longest command for padding
    let max_len = suggestion
        .commands
        .iter()
        .map(|c| c.len())
        .max()
        .unwrap_or(40)
        .max(40);

    let bar = "─".repeat(max_len + 8);
    println!("  {}{}{}",
        "┌".cyan(),
        bar.cyan(),
        "┐".cyan()
    );

    for cmd in &suggestion.commands {
        println!(
            "  {}  {}  {}  {}",
            "│".cyan(),
            "$".dimmed(),
            cmd.white().bold(),
            "│".cyan()
        );
    }

    println!("  {}{}{}",
        "└".cyan(),
        bar.cyan(),
        "┘".cyan()
    );
    println!();
}
