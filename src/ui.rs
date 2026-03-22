// =============================================================================
//  ui.rs — Terminal UI: banner, help text, suggestion display
// =============================================================================

use crate::ai::Suggestion;
use colored::Colorize;

// ── ASCII banner printed on every launch ─────────────────────────────────────
pub fn print_banner() {
    // Robot illustration + logotype
    // Designed to fit an 80-column terminal comfortably.
    println!();
    println!(
        "{}",
        r#"        ╔═══════════════════════════════════════════════════╗"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║                                                   ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║      ██╗   ██╗ ██████╗      ██████╗ ██╗   ██╗    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║      ╚██╗ ██╔╝██╔═══██╗     ██╔══██╗██║   ██║    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║       ╚████╔╝ ██║   ██║     ██████╔╝██║   ██║    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║        ╚██╔╝  ██║   ██║     ██╔══██╗██║   ██║    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║         ██║   ╚██████╔╝     ██║  ██║╚██████╔╝    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║         ╚═╝    ╚═════╝      ╚═╝  ╚═╝ ╚═════╝     ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║                                                   ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║         ██████╗ ██╗   ██╗███████╗████████╗        ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║         ██╔══██╗██║   ██║██╔════╝╚══██╔══╝        ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║         ██████╔╝██║   ██║███████╗   ██║           ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║         ██╔══██╗██║   ██║╚════██║   ██║           ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║         ██║  ██║╚██████╔╝███████║   ██║           ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║         ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝           ║"#
            .white()
            .bold()
    );
    println!(
        "{}",
        r#"        ║                                                   ║"#
            .cyan()
    );
    // Robot face
    println!(
        "{}",
        r#"        ║          ┌──────────────────────────┐             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │  ╔════╗  YO, RUST!  ╔════╗│             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │  ║ ◉  ║             ║  ◉ ║│             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │  ╚════╝             ╚════╝│             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │       ┌──────────┐        │             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │       │  ◌  ◌  ◌ │        │             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          │       └──────────┘        │             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║          └──────────────────────────┘             ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║             /\              /\                     ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║            /  \            /  \                    ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ║           /    \──────────/    \                   ║"#
            .cyan()
    );
    println!(
        "{}",
        r#"        ╚═══════════════════════════════════════════════════╝"#
            .cyan()
    );
    println!();
    println!(
        "        {}",
        "Natural language → Terminal commands, powered by AI.".dimmed()
    );
    println!();
}

// ── Short intro / usage hint ──────────────────────────────────────────────────
pub fn print_intro() {
    println!(
        "  {}  Type a task in plain English and I'll suggest the commands.",
        "►".cyan()
    );
    println!(
        "  {}  Type {} to see all options.",
        "►".cyan(),
        "!help".yellow().bold()
    );
    println!();
}

// ── Help text triggered by !help ──────────────────────────────────────────────
pub fn print_help() {
    println!();
    println!("{}", "  ╔══════════════════════════════════════════╗".cyan());
    println!("{}", "  ║              Yo, Rust! — Help            ║".cyan());
    println!("{}", "  ╚══════════════════════════════════════════╝".cyan());
    println!();
    println!("  {}", "USAGE".white().bold());
    println!(
        "    {}",
        "Just type your request in plain English, e.g.:".dimmed()
    );
    println!("    {}  {}", "yo ›".cyan().bold(), "list all .log files older than 7 days");
    println!("    {}  {}", "yo ›".cyan().bold(), "show the 20 biggest files in this folder");
    println!("    {}  {}", "yo ›".cyan().bold(), "kill the process on port 8080");
    println!();
    println!("  {}", "SHORTCUTS".white().bold());
    println!(
        "    {}   — display this help screen",
        "!help  / !h".yellow().bold()
    );
    println!(
        "    {}    — update your OpenRouter API key & model",
        "!api".yellow().bold()
    );
    println!(
        "    {}   — quit yo-rust",
        "!exit  / !q".yellow().bold()
    );
    println!();
    println!("  {}", "NAVIGATION".white().bold());
    println!("    {}  — accept and run the suggested command(s)", "Y".green().bold());
    println!("    {}  — decline, then refine your prompt", "N".red().bold());
    println!("    {}  — exit yo-rust at any time", "Ctrl+D".dimmed());
    println!();
    println!("  {}", "CONFIG".white().bold());
    println!(
        "    {}",
        "Config is stored at:  ~/.config/yo-rust/config.json".dimmed()
    );
    println!();
}

// ── Print suggested command(s) from the AI ───────────────────────────────────
pub fn print_suggestion(suggestion: &Suggestion) {
    println!();

    // Print optional explanation
    if let Some(ref explanation) = suggestion.explanation {
        println!(
            "  {}  {}",
            "◈".cyan(),
            explanation.dimmed()
        );
        println!();
    }

    if suggestion.commands.is_empty() {
        println!(
            "  {}",
            "No commands were suggested for this request.".yellow()
        );
        println!();
        return;
    }

    // Print each command in a styled block
    println!("{}", "  ┌─────────────────────────────────────────────┐".cyan());
    for cmd in &suggestion.commands {
        println!(
            "  {}  {}  {}",
            "│".cyan(),
            "  $".dimmed(),
            cmd.white().bold()
        );
    }
    println!("{}", "  └─────────────────────────────────────────────┘".cyan());
    println!();
}
