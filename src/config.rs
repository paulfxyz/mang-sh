// =============================================================================
//  config.rs — Persistent configuration for yo-rust
//
//  Config is stored as a plain JSON file at:
//    ~/.config/yo-rust/config.json
//
//  Fields:
//    api_key  — OpenRouter API key (sk-or-…)
//    model    — model slug, e.g. "openai/gpt-4o-mini"
// =============================================================================

use std::fs;
use std::io::{self, Write};
use std::path::PathBuf;

use colored::Colorize;
use serde::{Deserialize, Serialize};

// ── Data structure stored on disk ────────────────────────────────────────────
#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Config {
    #[serde(default)]
    pub api_key: String,

    #[serde(default)]
    pub model: String,
}

// ── Resolve the config file path ─────────────────────────────────────────────
fn config_path() -> PathBuf {
    let base = dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."));
    base.join("yo-rust").join("config.json")
}

// ── Load config from disk; returns a default if the file doesn't exist yet ───
pub fn load() -> Result<Config, Box<dyn std::error::Error>> {
    let path = config_path();
    if !path.exists() {
        return Ok(Config::default());
    }
    let raw = fs::read_to_string(&path)?;
    let cfg: Config = serde_json::from_str(&raw)?;
    Ok(cfg)
}

// ── Persist config to disk ───────────────────────────────────────────────────
pub fn save(cfg: &Config) -> Result<(), Box<dyn std::error::Error>> {
    let path = config_path();
    // Create the directory if it doesn't exist yet
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let json = serde_json::to_string_pretty(cfg)?;
    fs::write(&path, json)?;
    Ok(())
}

// ── Interactive setup: prompt the user for an API key and model ───────────────
pub fn interactive_setup(cfg: &mut Config) {
    println!();
    println!("{}", "  ╔══════════════════════════════════════════╗".cyan());
    println!("{}", "  ║         OpenRouter Configuration         ║".cyan());
    println!("{}", "  ╚══════════════════════════════════════════╝".cyan());
    println!();
    println!(
        "  {}",
        "Get your free API key at: https://openrouter.ai/keys".dimmed()
    );
    println!();

    // ── API key ───────────────────────────────────────────────────────────────
    loop {
        print!("  {}  ", "OpenRouter API key ›".yellow().bold());
        io::stdout().flush().unwrap_or(());

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap_or(0);
        let key = input.trim().to_string();

        if key.is_empty() {
            println!("{}", "  ✗  API key cannot be empty.".red());
            continue;
        }
        cfg.api_key = key;
        break;
    }

    // ── Model selection ───────────────────────────────────────────────────────
    println!();
    println!("  {}", "Choose a model (leave blank for default):".white());
    println!("  {}", "  1) openai/gpt-4o-mini          (fast, cheap)".dimmed());
    println!("  {}", "  2) openai/gpt-4o               (powerful)".dimmed());
    println!("  {}", "  3) anthropic/claude-3-haiku     (very fast)".dimmed());
    println!("  {}", "  4) anthropic/claude-3.5-sonnet  (best reasoning)".dimmed());
    println!("  {}", "  5) meta-llama/llama-3.3-70b-instruct:free  (free tier)".dimmed());
    println!("  {}", "  Or type any OpenRouter model slug directly.".dimmed());
    println!();

    print!("  {}  ", "Model ›".yellow().bold());
    io::stdout().flush().unwrap_or(());

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or(0);
    let choice = input.trim().to_string();

    cfg.model = match choice.as_str() {
        "" | "1" => "openai/gpt-4o-mini".to_string(),
        "2"      => "openai/gpt-4o".to_string(),
        "3"      => "anthropic/claude-3-haiku".to_string(),
        "4"      => "anthropic/claude-3.5-sonnet".to_string(),
        "5"      => "meta-llama/llama-3.3-70b-instruct:free".to_string(),
        custom   => custom.to_string(),
    };

    println!();
    println!(
        "  {}  model: {}",
        "✔  Saved →".green().bold(),
        cfg.model.cyan()
    );
}
