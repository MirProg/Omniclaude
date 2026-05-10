<#
.SYNOPSIS
    Claude Code via OmniRoute - One-Click Launcher
.DESCRIPTION
    Ensures OmniRoute is running, sets up environment variables,
    and launches Claude Code pointing at your local OmniRoute gateway.
    Uses the "steak" combo (Priority fallback: Gemini > GitHub/Claude > Groq/Llama).
#>

# -- Configuration -------------------------------------------------------
$OMNIROUTE_EXE   = "$env:USERPROFILE\Documents\Downloads\OmniRoute.3.7.9.exe"
$OMNIROUTE_URL   = "http://localhost:20128"
$API_KEY         = "sk-41af87422307324d-ce6f75-57925a62"
$COMBO_MODEL     = "steak"
$CLAUDE_CMD      = "claude"

# -- Helpers --------------------------------------------------------------
function Write-Step {
    param([string]$Status, [string]$Text, [string]$Color = "White")
    Write-Host "  [$Status] " -NoNewline -ForegroundColor $Color
    Write-Host $Text
}

# -- Start ----------------------------------------------------------------
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor DarkCyan
Write-Host "  ||  Claude Code x OmniRoute Launcher                      ||" -ForegroundColor Cyan
Write-Host "  ============================================================" -ForegroundColor DarkCyan
Write-Host ""

# 1) Check / Start OmniRoute ---------------------------------------------
$omniProcess = Get-Process -Name "OmniRoute*" -ErrorAction SilentlyContinue
if ($omniProcess) {
    Write-Step "OK" "OmniRoute is already running (PID $($omniProcess[0].Id))" "Green"
}
else {
    Write-Step ".." "Starting OmniRoute..." "Yellow"
    if (Test-Path $OMNIROUTE_EXE) {
        Start-Process -FilePath $OMNIROUTE_EXE -WindowStyle Minimized
        Write-Step ".." "Waiting for OmniRoute to initialize..." "Yellow"
        $retries = 0
        $maxRetries = 30
        while ($retries -lt $maxRetries) {
            Start-Sleep -Seconds 1
            try {
                $headers = @{ "Authorization" = "Bearer $API_KEY" }
                $null = Invoke-WebRequest -Uri "$OMNIROUTE_URL/v1/models" -Headers $headers -TimeoutSec 2 -ErrorAction Stop
                break
            }
            catch {
                $retries++
            }
        }
        if ($retries -ge $maxRetries) {
            Write-Step "!!" "OmniRoute failed to start within 30 seconds!" "Red"
            Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
        Write-Step "OK" "OmniRoute started successfully!" "Green"
    }
    else {
        Write-Step "!!" "OmniRoute executable not found at: $OMNIROUTE_EXE" "Red"
        Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# 2) Verify connectivity -------------------------------------------------
Write-Step ".." "Verifying OmniRoute connectivity..." "Yellow"
try {
    $headers = @{ "Authorization" = "Bearer $API_KEY" }
    $models = Invoke-RestMethod -Uri "$OMNIROUTE_URL/v1/models" -Headers $headers -TimeoutSec 5 -ErrorAction Stop
    $modelCount = $models.data.Count
    $comboExists = $models.data | Where-Object { $_.id -eq $COMBO_MODEL }
    Write-Step "OK" "$modelCount models available" "Green"
    if ($comboExists) {
        Write-Step "OK" "Combo '$COMBO_MODEL' is active" "Green"
    }
    else {
        Write-Step "??" "Combo '$COMBO_MODEL' not found - will still work but without fallback" "Yellow"
    }
}
catch {
    Write-Step "!!" "Cannot connect to OmniRoute at $OMNIROUTE_URL" "Red"
    Write-Step "  " "Error: $_" "DarkGray"
    Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 3) Set environment variables --------------------------------------------
Write-Step ".." "Configuring Claude Code environment..." "Yellow"

$env:ANTHROPIC_BASE_URL = "$OMNIROUTE_URL/v1"
$env:ANTHROPIC_API_KEY  = $API_KEY
$env:OPENAI_BASE_URL    = "$OMNIROUTE_URL/v1"
$env:OPENAI_API_KEY     = $API_KEY

Write-Step "OK" "ANTHROPIC_BASE_URL = $OMNIROUTE_URL/v1" "Green"
Write-Step "OK" "OPENAI_BASE_URL    = $OMNIROUTE_URL/v1" "Green"
Write-Step "OK" "API keys configured" "Green"

# 4) Show configuration summary -------------------------------------------
Write-Host ""
Write-Host "  +---------------------------------------------------+" -ForegroundColor DarkCyan
Write-Host "  |  Gateway:   OmniRoute v3.7.9 @ localhost:20128    |" -ForegroundColor Gray
Write-Host "  |  Combo:     steak (Priority Fallback)             |" -ForegroundColor Gray
Write-Host "  |  Chain:     Gemini > Claude > Groq/Llama          |" -ForegroundColor Gray
Write-Host "  |  Filters:   reasoning_effort, thinking            |" -ForegroundColor Gray
Write-Host "  +---------------------------------------------------+" -ForegroundColor DarkCyan
Write-Host ""

cmd.exe /c "$CLAUDE_CMD --model $COMBO_MODEL"

Write-Host ""
Write-Host "  Session ended. Press any key to close..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

