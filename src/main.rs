// =============================================================================
//  yo-rust — Natural Language Terminal Assistant
//  https://github.com/paulfxyz/yo-rust
//
//  Entry point.  Handles argument parsing, the REPL loop, and wires together
//  the config, ai, and ui sub-modules.
// =============================================================================

mod ai;
mod config;
mod ui;

use std::process;
use colored::Colorize;
use rustyline::error::ReadlineError;
use rustyline::DefaultEditor;

fn main() {
    // ── Print the welcome banner ─────────────────────────────────────────────
    ui::print_banner();

    // ── Load or initialise configuration ────────────────────────────────────
    let mut cfg = match config::load() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{}", format!("  ✗  Could not read config: {e}").red());
            process::exit(1);
        }
    };

    // ── First-run: ask for API key + model if not yet configured ─────────────
    if cfg.api_key.is_empty() {
        println!(
            "\n{}",
            "  ◈  First run detected — let's get you set up.".yellow().bold()
        );
        config::interactive_setup(&mut cfg);
        if let Err(e) = config::save(&cfg) {
            eprintln!("{}", format!("  ✗  Could not save config: {e}").red());
        }
    }

    // ── Short intro line ─────────────────────────────────────────────────────
    ui::print_intro();

    // ── Main REPL loop ───────────────────────────────────────────────────────
    let mut rl = DefaultEditor::new().unwrap_or_else(|e| {
        eprintln!("{}", format!("  ✗  Readline init failed: {e}").red());
        process::exit(1);
    });

    loop {
        // Prompt the user for input
        let line = match rl.readline(&format!("{} ", "  yo ›".cyan().bold())) {
            Ok(l) => {
                let trimmed = l.trim().to_string();
                if !trimmed.is_empty() {
                    let _ = rl.add_history_entry(&trimmed);
                }
                trimmed
            }
            // Ctrl-D → clean exit
            Err(ReadlineError::Eof) => {
                println!("\n{}", "  Later. ✌".dimmed());
                break;
            }
            // Ctrl-C → clean exit
            Err(ReadlineError::Interrupted) => {
                println!("\n{}", "  Interrupted. Later. ✌".dimmed());
                break;
            }
            Err(e) => {
                eprintln!("{}", format!("  ✗  Input error: {e}").red());
                break;
            }
        };

        if line.is_empty() {
            continue;
        }

        // ── Handle built-in shortcuts ────────────────────────────────────────
        match line.as_str() {
            "!help" | "!h" => {
                ui::print_help();
                continue;
            }
            "!api" => {
                config::interactive_setup(&mut cfg);
                if let Err(e) = config::save(&cfg) {
                    eprintln!("{}", format!("  ✗  Could not save config: {e}").red());
                }
                println!("{}", "  ✔  API key & model updated.".green());
                continue;
            }
            "!exit" | "!quit" | "!q" => {
                println!("{}", "  Later. ✌".dimmed());
                break;
            }
            _ => {}
        }

        // ── Detect natural language intent to change API key ─────────────────
        if ai::intent_is_api_change(&line) {
            println!(
                "{}",
                "  ◈  Sounds like you want to update your API config.".yellow()
            );
            config::interactive_setup(&mut cfg);
            if let Err(e) = config::save(&cfg) {
                eprintln!("{}", format!("  ✗  Could not save config: {e}").red());
            }
            println!("{}", "  ✔  API key & model updated.".green());
            continue;
        }

        // ── Send prompt to OpenRouter, receive suggested command(s) ──────────
        println!("{}", "  ◌  Thinking…".dimmed());

        match ai::suggest_commands(&cfg, &line) {
            Err(e) => {
                eprintln!("{}", format!("  ✗  AI request failed: {e}").red());
            }
            Ok(suggestion) => {
                // Pretty-print the suggested command block
                ui::print_suggestion(&suggestion);

                // ── Y / N confirmation loop ───────────────────────────────
                loop {
                    let answer =
                        match rl.readline(&format!("{} ", "  Run it? [Y/n] ›".yellow().bold())) {
                            Ok(a) => a.trim().to_lowercase(),
                            Err(_) => String::from("n"),
                        };

                    match answer.as_str() {
                        // ── YES: execute the commands ─────────────────────
                        "y" | "yes" | "" => {
                            execute_commands(&suggestion.commands);
                            break;
                        }
                        // ── NO: let the user refine their prompt ──────────
                        "n" | "no" => {
                            println!(
                                "{}",
                                "  ◈  No worries — adjust your prompt and try again."
                                    .dimmed()
                            );
                            break;
                        }
                        _ => {
                            println!(
                                "{}",
                                "  Please type Y (yes) or N (no).".yellow()
                            );
                        }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Execute a list of shell commands sequentially, streaming their output.
// ─────────────────────────────────────────────────────────────────────────────
fn execute_commands(commands: &[String]) {
    for cmd in commands {
        println!(
            "\n{}  {}",
            "  ►".green().bold(),
            cmd.white().bold()
        );

        let status = std::process::Command::new("sh")
            .arg("-c")
            .arg(cmd)
            // Inherit stdin / stdout / stderr so interactive commands work
            .stdin(std::process::Stdio::inherit())
            .stdout(std::process::Stdio::inherit())
            .stderr(std::process::Stdio::inherit())
            .status();

        match status {
            Ok(s) if s.success() => {
                println!("{}", "  ✔  Done.".green());
            }
            Ok(s) => {
                eprintln!(
                    "{}",
                    format!("  ✗  Command exited with status {s}").red()
                );
            }
            Err(e) => {
                eprintln!("{}", format!("  ✗  Failed to run command: {e}").red());
            }
        }
    }
}
