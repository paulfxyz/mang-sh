# =============================================================================
#  update.ps1 -- Update yo-rust to the latest version (Windows / PowerShell)
#  https://github.com/paulfxyz/yo-rust
#
#  Usage:
#    iwr -useb https://raw.githubusercontent.com/paulfxyz/yo-rust/main/update.ps1 | iex
#
#  What it does:
#    1. Finds the currently installed yo.exe and reads its version
#    2. Fetches the latest version number from GitHub
#    3. Exits early if already up to date
#    4. Downloads source ZIP, builds, and replaces the binary in-place
#    5. Never touches your config or aliases
# =============================================================================

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Log-Info  { param($msg) Write-Host "  [..] $msg"  -ForegroundColor Cyan }
function Log-OK    { param($msg) Write-Host "  [ok] $msg"  -ForegroundColor Green }
function Log-Warn  { param($msg) Write-Host "  [!!] $msg"  -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "  [!!] $msg"  -ForegroundColor Red; exit 1 }

$REPO_URL  = "https://github.com/paulfxyz/yo-rust"
$RAW_BASE  = "https://raw.githubusercontent.com/paulfxyz/yo-rust/main"
$ZIP_URL   = "https://github.com/paulfxyz/yo-rust/archive/refs/heads/main.zip"
$TMP_DIR   = Join-Path $env:TEMP "yo-rust-update-$(Get-Random)"

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |          Updating  Yo, Rust!            |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# -- Step 1: Find existing binary ---------------------------------------------
$YoBin = Get-Command yo -ErrorAction SilentlyContinue
if (-not $YoBin) {
    # Check common install location
    $DefaultPath = Join-Path $env:LOCALAPPDATA "yo-rust\bin\yo.exe"
    if (Test-Path $DefaultPath) {
        $YoBinPath = $DefaultPath
    } else {
        Log-Warn "yo-rust does not appear to be installed."
        Write-Host "      Install it first:" -ForegroundColor DarkGray
        Write-Host "      iwr -useb $RAW_BASE/install.ps1 | iex" -ForegroundColor DarkGray
        Write-Host ""
        exit 1
    }
} else {
    $YoBinPath = $YoBin.Source
}

Log-OK "Found yo at: $YoBinPath"

# -- Step 2: Read installed version -------------------------------------------
$InstalledVersion = "unknown"
try {
    # Read version string from binary content
    $BinaryContent = [System.IO.File]::ReadAllBytes($YoBinPath)
    $BinaryText = [System.Text.Encoding]::ASCII.GetString($BinaryContent) -replace '[^\x20-\x7E]', ' '
    $Match = [regex]::Match($BinaryText, 'v(\d+\.\d+\.\d+)')
    if ($Match.Success) { $InstalledVersion = $Match.Value }
} catch { }
Write-Host "      Installed: $InstalledVersion" -ForegroundColor DarkGray

# -- Step 3: Fetch latest version ---------------------------------------------
Log-Info "Checking latest version on GitHub..."
try {
    $CargoToml = (Invoke-WebRequest -Uri "$RAW_BASE/Cargo.toml" -UseBasicParsing -TimeoutSec 10).Content
    $LatestVersion = [regex]::Match($CargoToml, 'version\s*=\s*"([^"]+)"').Groups[1].Value
} catch {
    Log-Error "Could not reach GitHub. Check your connection."
}
Write-Host "      Latest:    v$LatestVersion" -ForegroundColor DarkGray

# -- Step 4: Early exit if up to date ----------------------------------------
if ($InstalledVersion -eq "v$LatestVersion") {
    Write-Host ""
    Log-OK "Already up to date ($InstalledVersion). Nothing to do."
    Write-Host ""
    exit 0
}

Write-Host ""
Log-Info "Updating $InstalledVersion --> v$LatestVersion..."
Write-Host ""

# -- Step 5: Ensure Rust is available ----------------------------------------
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + $env:PATH
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Log-Error "Rust/Cargo not found. Run install.ps1 to reinstall (it will install Rust)."
}

# -- Step 6: Download and build -----------------------------------------------
New-Item -ItemType Directory -Force -Path $TMP_DIR | Out-Null
Log-Info "Downloading latest source..."
try {
    $ZipPath = Join-Path $TMP_DIR "yo-rust.zip"
    Invoke-WebRequest -Uri $ZIP_URL -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $TMP_DIR -Force
    Remove-Item $ZipPath -Force
} catch {
    Log-Error "Download failed: $_"
}

$SrcDir = Join-Path $TMP_DIR "yo-rust-main"
if (-not (Test-Path $SrcDir)) {
    $SrcDir = (Get-ChildItem $TMP_DIR -Directory | Select-Object -First 1).FullName
}

Log-Info "Building release binary..."
Push-Location $SrcDir
& cargo build --release 2>&1 | Out-Null
Pop-Location

$NewBinary = Join-Path $SrcDir "target\release\yo.exe"
if (-not (Test-Path $NewBinary)) {
    Log-Error "Build succeeded but yo.exe not found. Please open an issue at $REPO_URL/issues"
}
Log-OK "Build complete."

# -- Step 7: Replace binary ---------------------------------------------------
Copy-Item -Path $NewBinary -Destination $YoBinPath -Force
Log-OK "Binary updated at: $YoBinPath"

# -- Cleanup ------------------------------------------------------------------
Remove-Item -Recurse -Force $TMP_DIR -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |           Update complete!              |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  yo-rust v$LatestVersion is ready." -ForegroundColor Green
Write-Host "  Your config was not changed." -ForegroundColor DarkGray
Write-Host ""
