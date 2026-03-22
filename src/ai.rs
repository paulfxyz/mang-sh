// =============================================================================
//  ai.rs — OpenRouter API integration
//
//  Responsibilities:
//    • Build a structured system prompt that asks the model to output ONLY
//      valid shell commands, one per line, wrapped in a JSON envelope.
//    • Detect whether the user's natural language prompt is asking to
//      change / update the API key.
//    • Parse the model response into a `Suggestion` struct.
// =============================================================================

use crate::config::Config;
use regex::Regex;
use serde::{Deserialize, Serialize};

// ── Public result type returned to main ──────────────────────────────────────
#[derive(Debug)]
pub struct Suggestion {
    /// One or more shell commands to run in sequence
    pub commands: Vec<String>,
    /// Optional explanation sentence from the model
    pub explanation: Option<String>,
}

// ── OpenRouter request / response shapes ─────────────────────────────────────
#[derive(Serialize)]
struct ChatRequest<'a> {
    model: &'a str,
    messages: Vec<Message<'a>>,
    temperature: f32,
    max_tokens: u32,
}

#[derive(Serialize)]
struct Message<'a> {
    role: &'a str,
    content: &'a str,
}

#[derive(Deserialize)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Deserialize)]
struct Choice {
    message: ResponseMessage,
}

#[derive(Deserialize)]
struct ResponseMessage {
    content: String,
}

// ── System prompt ─────────────────────────────────────────────────────────────
//  The model must ALWAYS reply with a JSON object that follows this schema:
//  {
//    "commands": ["cmd1", "cmd2", ...],
//    "explanation": "One sentence explaining what the commands do."
//  }
//  This makes parsing reliable and keeps the UX clean.
const SYSTEM_PROMPT: &str = r#"You are yo-rust, a terminal assistant that converts natural language requests into shell commands.

RULES:
1. Reply ONLY with a JSON object — no prose, no markdown fences, no extra text.
2. The JSON must match this exact schema:
   {
     "commands": ["<cmd1>", "<cmd2>"],
     "explanation": "<one concise sentence describing what the commands do>"
   }
3. Produce the minimal set of commands required — prefer composable one-liners.
4. Commands must be POSIX-compatible (sh/bash). Prefer portable syntax.
5. Never suggest destructive commands (rm -rf /, mkfs, dd to disk, etc.) without adding a clear safety flag or comment.
6. If the request is ambiguous, make the safest reasonable assumption.
7. If the request cannot be expressed as shell commands, return:
   { "commands": [], "explanation": "I cannot express this as a shell command." }
"#;

// ── Main API call ─────────────────────────────────────────────────────────────
pub fn suggest_commands(
    cfg: &Config,
    user_prompt: &str,
) -> Result<Suggestion, Box<dyn std::error::Error>> {
    // Gather a little context about the current environment to help the model
    let ctx = build_context();
    let augmented = format!(
        "System context: {ctx}\n\nUser request: {user_prompt}",
    );

    let request_body = ChatRequest {
        model: &cfg.model,
        messages: vec![
            Message {
                role: "system",
                content: SYSTEM_PROMPT,
            },
            Message {
                role: "user",
                content: &augmented,
            },
        ],
        temperature: 0.2, // Low temp → more deterministic, safer commands
        max_tokens: 512,
    };

    let client = reqwest::blocking::Client::new();
    let resp = client
        .post("https://openrouter.ai/api/v1/chat/completions")
        .header("Authorization", format!("Bearer {}", cfg.api_key))
        .header("Content-Type", "application/json")
        // Required by OpenRouter for rate-limit tracking
        .header("HTTP-Referer", "https://github.com/paulfxyz/yo-rust")
        .header("X-Title", "yo-rust")
        .json(&request_body)
        .send()?;

    if !resp.status().is_success() {
        let status = resp.status();
        let body = resp.text().unwrap_or_default();
        return Err(format!("OpenRouter returned {status}: {body}").into());
    }

    let chat: ChatResponse = resp.json()?;

    let raw_content = chat
        .choices
        .into_iter()
        .next()
        .map(|c| c.message.content)
        .ok_or("Empty response from model")?;

    parse_suggestion(&raw_content)
}

// ── Parse the JSON envelope from the model response ──────────────────────────
fn parse_suggestion(raw: &str) -> Result<Suggestion, Box<dyn std::error::Error>> {
    // Strip any accidental markdown code fences the model may have added
    let cleaned = raw
        .trim()
        .trim_start_matches("```json")
        .trim_start_matches("```")
        .trim_end_matches("```")
        .trim();

    // Attempt JSON parse
    let v: serde_json::Value = serde_json::from_str(cleaned)
        .map_err(|e| format!("Could not parse model response as JSON: {e}\nRaw: {cleaned}"))?;

    let commands: Vec<String> = v
        .get("commands")
        .and_then(|c| c.as_array())
        .map(|arr| {
            arr.iter()
                .filter_map(|x| x.as_str())
                .map(|s| s.to_string())
                .collect()
        })
        .unwrap_or_default();

    let explanation = v
        .get("explanation")
        .and_then(|e| e.as_str())
        .map(|s| s.to_string());

    Ok(Suggestion {
        commands,
        explanation,
    })
}

// ── Intent detection: is the user asking to change their API key? ─────────────
//  Uses a simple regex heuristic — intentionally low-tech and fast.
pub fn intent_is_api_change(prompt: &str) -> bool {
    let lower = prompt.to_lowercase();
    // Patterns that strongly suggest an API-change intent
    let patterns = [
        r"change.*api",
        r"update.*api",
        r"new.*api.*key",
        r"set.*api.*key",
        r"switch.*model",
        r"change.*model",
        r"update.*model",
        r"different.*model",
    ];
    for pat in &patterns {
        if let Ok(re) = Regex::new(pat) {
            if re.is_match(&lower) {
                return true;
            }
        }
    }
    false
}

// ── Build a minimal context string about the running system ──────────────────
fn build_context() -> String {
    let os = std::env::consts::OS;
    let arch = std::env::consts::ARCH;

    // Current working directory
    let cwd = std::env::current_dir()
        .map(|p| p.display().to_string())
        .unwrap_or_else(|_| "unknown".to_string());

    // Shell (SHELL env var; fallback to "sh")
    let shell = std::env::var("SHELL").unwrap_or_else(|_| "sh".to_string());

    format!("OS={os} ARCH={arch} CWD={cwd} SHELL={shell}")
}
