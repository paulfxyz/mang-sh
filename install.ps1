# =============================================================================
#  install.ps1 -- Install yo-rust on Windows (PowerShell 5+ / PowerShell 7+)
#  https://github.com/paulfxyz/yo-rust
#
#  Usage -- run this in any PowerShell window (PS5 or PS7):
#
#    iwr -useb https://raw.githubusercontent.com/paulfxyz/yo-rust/main/install.ps1 | iex
#
#  Or save locally and run:
#
#    powershell -ExecutionPolicy Bypass -File install.ps1
#
#  WHY THIS SCRIPT EXISTS
#  ──────────────────────
#  On Windows, `curl` is an alias for Invoke-WebRequest, not the real curl
#  binary.  Invoke-WebRequest does not accept -fsSL flags, so the Unix install
#  command (curl -fsSL ... | bash) fails immediately in PowerShell.
#  Additionally, `bash` is not available in native Windows PowerShell without
#  Git Bash or WSL2 installed, so even if the download succeeded, the script
#  could not run.
#
#  This script is the native Windows equivalent of yo.sh.  It does the same
#  job using only PowerShell built-ins (Invoke-WebRequest, Expand-Archive,
#  Start-Process) and winget/cargo for Rust installation.
#
#  WHAT IT DOES
#  ────────────
#  1. Detects if yo is already installed and shows the current version
#  2. Checks for Rust/Cargo -- installs via rustup-init.exe if missing
#  3. Clones (or downloads ZIP of) the repo and builds a release binary
#  4. Installs yo.exe to a user-writable location added to $PATH
#  5. Sets yo, hi, hello as PowerShell aliases via $PROFILE
#
#  INSTALL LOCATION
#  ────────────────
#  Default: $env:LOCALAPPDATA\yo-rust\bin\yo.exe
#  This is always user-writable (no UAC prompt needed).
#  The directory is added to $env:PATH in $PROFILE for the current user.
#
#  EXECUTION POLICY NOTE
#  ─────────────────────
#  If you get "running scripts is disabled on this system":
#    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#  Or run the one-liner with:
#    powershell -ExecutionPolicy Bypass -Command "iwr -useb URL | iex"
# =============================================================================

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Colours via Write-Host ---------------------------------------------------
function Log-Info  { param($msg) Write-Host "  [..] $msg"  -ForegroundColor Cyan }
function Log-OK    { param($msg) Write-Host "  [ok] $msg"  -ForegroundColor Green }
function Log-Warn  { param($msg) Write-Host "  [!!] $msg"  -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "  [!!] $msg"  -ForegroundColor Red; exit 1 }

# -- Constants ----------------------------------------------------------------
$REPO_URL   = "https://github.com/paulfxyz/yo-rust"
$RAW_BASE   = "https://raw.githubusercontent.com/paulfxyz/yo-rust/main"
$ZIP_URL    = "https://github.com/paulfxyz/yo-rust/archive/refs/heads/main.zip"
$INSTALL_DIR = Join-Path $env:LOCALAPPDATA "yo-rust\bin"
$TMP_DIR    = Join-Path $env:TEMP "yo-rust-install-$(Get-Random)"

# -- Banner -------------------------------------------------------------------
Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |        Installing  Yo, Rust!            |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# -- Step 1: Detect existing install ------------------------------------------
$ExistingBin = Get-Command yo -ErrorAction SilentlyContinue
if ($ExistingBin) {
    # Try to extract version from the binary using Select-String
    $ExistingVersion = try {
        $str = & strings $ExistingBin.Source 2>$null | Select-String -Pattern 'v\d+\.\d+\.\d+' | Select-Object -First 1
        if ($str) { $str.Matches[0].Value } else { "unknown" }
    } catch { "unknown" }
    Log-Warn "yo is already installed at $($ExistingBin.Source) ($ExistingVersion)"
    Write-Host "      Reinstalling will replace the binary. Your config is safe." -ForegroundColor DarkGray
    Write-Host ""
}

# Fetch latest version from Cargo.toml for display
try {
    $CargoToml = (Invoke-WebRequest -Uri "$RAW_BASE/Cargo.toml" -UseBasicParsing -TimeoutSec 10).Content
    $LatestVersion = [regex]::Match($CargoToml, 'version\s*=\s*"([^"]+)"').Groups[1].Value
    Write-Host "      Target version: v$LatestVersion" -ForegroundColor DarkGray
    Write-Host ""
} catch {
    $LatestVersion = "latest"
}

# -- Step 2: Check / install Rust ---------------------------------------------
$CargoExe = Get-Command cargo -ErrorAction SilentlyContinue
if (-not $CargoExe) {
    # Try refreshing PATH (Rust may have just been installed in this session)
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + $env:PATH
    $CargoExe = Get-Command cargo -ErrorAction SilentlyContinue
}

if (-not $CargoExe) {
    Log-Warn "Rust not found. Installing via rustup..."
    Write-Host "      Downloading rustup-init.exe..." -ForegroundColor DarkGray

    $RustupInstaller = Join-Path $env:TEMP "rustup-init.exe"
    try {
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $RustupInstaller -UseBasicParsing
    } catch {
        Log-Error "Could not download rustup-init.exe. Check your internet connection."
    }

    # Run rustup in quiet mode, install stable toolchain, no PATH modification yet
    $RustupProcess = Start-Process -FilePath $RustupInstaller `
        -ArgumentList "-y", "--quiet", "--default-toolchain", "stable" `
        -Wait -PassThru -NoNewWindow
    Remove-Item $RustupInstaller -Force -ErrorAction SilentlyContinue

    if ($RustupProcess.ExitCode -ne 0) {
        Log-Error "Rust installation failed. Install manually from https://rustup.rs"
    }

    # Reload PATH to pick up cargo
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                (Join-Path $env:USERPROFILE ".cargo\bin")

    $CargoExe = Get-Command cargo -ErrorAction SilentlyContinue
    if (-not $CargoExe) {
        Log-Error "Cargo still not found after Rust install. Please restart PowerShell and re-run this script."
    }
    Log-OK "Rust installed."
} else {
    $RustVersion = (& rustc --version 2>&1)
    Log-OK "Rust: $RustVersion"
}

# -- Step 3: Download source ZIP and build ------------------------------------
Log-Info "Downloading yo-rust source..."
try {
    New-Item -ItemType Directory -Force -Path $TMP_DIR | Out-Null
    $ZipPath = Join-Path $TMP_DIR "yo-rust.zip"
    Invoke-WebRequest -Uri $ZIP_URL -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $TMP_DIR -Force
    Remove-Item $ZipPath -Force
} catch {
    Log-Error "Could not download source: $_"
}

# The extracted folder is named yo-rust-main
$SrcDir = Join-Path $TMP_DIR "yo-rust-main"
if (-not (Test-Path $SrcDir)) {
    # Fallback: find whatever directory was created
    $SrcDir = (Get-ChildItem $TMP_DIR -Directory | Select-Object -First 1).FullName
}

Log-Info "Building release binary (first build ~2 min, reinstalls are faster)..."
try {
    Push-Location $SrcDir
    $BuildResult = & cargo build --release 2>&1
    Pop-Location
} catch {
    Pop-Location -ErrorAction SilentlyContinue
    Log-Error "Build failed: $_"
}

$BinaryPath = Join-Path $SrcDir "target\release\yo.exe"
if (-not (Test-Path $BinaryPath)) {
    Log-Error "Build succeeded but yo.exe not found at expected location. Please open an issue at $REPO_URL/issues"
}
Log-OK "Build complete."

# -- Step 4: Install binary ---------------------------------------------------
# Use the existing install location if reinstalling, otherwise use LOCALAPPDATA
if ($ExistingBin -and (Test-Path $ExistingBin.Source)) {
    $TargetDir = Split-Path $ExistingBin.Source
    $TargetPath = $ExistingBin.Source
} else {
    $TargetDir = $INSTALL_DIR
    $TargetPath = Join-Path $INSTALL_DIR "yo.exe"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item -Path $BinaryPath -Destination $TargetPath -Force
Log-OK "Installed: $TargetPath"

# -- Step 5: Add install directory to PATH ------------------------------------
$UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$TargetDir*") {
    [System.Environment]::SetEnvironmentVariable(
        "PATH",
        "$UserPath;$TargetDir",
        "User"
    )
    # Also update PATH for the current session immediately
    $env:PATH = "$env:PATH;$TargetDir"
    Log-OK "Added $TargetDir to your user PATH."
} else {
    Log-OK "PATH already includes $TargetDir"
}

# -- Step 6: PowerShell aliases in $PROFILE -----------------------------------
# We add aliases to $PROFILE so `yo`, `hi`, and `hello` all work in future PS sessions.
# We also create the alias for the current session immediately.

$AliasBlock = @"

# yo-rust aliases -- added by install.ps1
Set-Alias -Name yo    -Value "$TargetPath" -Option AllScope -Scope Global
Set-Alias -Name hi    -Value "$TargetPath" -Option AllScope -Scope Global
Set-Alias -Name hello -Value "$TargetPath" -Option AllScope -Scope Global
"@

# Set for this session immediately
Set-Alias -Name yo    -Value $TargetPath -Option AllScope -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name hi    -Value $TargetPath -Option AllScope -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name hello -Value $TargetPath -Option AllScope -Scope Global -ErrorAction SilentlyContinue

# Persist to $PROFILE
if ($PROFILE) {
    # Create profile file if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Force -Path $PROFILE | Out-Null
    }
    $ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if (-not ($ProfileContent -like "*yo-rust aliases*")) {
        Add-Content -Path $PROFILE -Value $AliasBlock
        Log-OK "Aliases added to $PROFILE  (yo / hi / hello)"
    } else {
        Log-OK "Aliases already present in $PROFILE"
    }
} else {
    Log-Warn "Could not determine PowerShell profile path. Add aliases manually:"
    Write-Host "      Set-Alias -Name yo -Value `"$TargetPath`"" -ForegroundColor DarkGray
}

# -- Step 7: Cleanup ----------------------------------------------------------
Remove-Item -Recurse -Force $TMP_DIR -ErrorAction SilentlyContinue

# -- Done ---------------------------------------------------------------------
Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |        Installation complete!           |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Type  " -NoNewline
Write-Host "yo" -ForegroundColor Cyan -NoNewline
Write-Host "  to start. (Works in this window already.)"
Write-Host ""
Write-Host "  For future windows, restart PowerShell so PATH updates take effect." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Update:    " -NoNewline -ForegroundColor DarkGray
Write-Host "iwr -useb $RAW_BASE/update.ps1 | iex" -ForegroundColor DarkGray
Write-Host "  Uninstall: " -NoNewline -ForegroundColor DarkGray
Write-Host "iwr -useb $RAW_BASE/uninstall.ps1 | iex" -ForegroundColor DarkGray
Write-Host ""
