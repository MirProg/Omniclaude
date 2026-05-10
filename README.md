# Claude Code × OmniRoute Launcher

A one-click desktop launcher for Windows that connects [Claude Code](https://github.com/anthropics/claude-code) to the [OmniRoute](https://github.com/diegosouzapw/OmniRoute) local AI gateway. 

## Features
- **Auto-starts OmniRoute**: Checks if OmniRoute is running on port 20128 and automatically boots it in the background if it isn't.
- **Environment Configuration**: Automatically injects `ANTHROPIC_BASE_URL` and `OPENAI_BASE_URL` to route through your local OmniRoute instance.
- **Combo Fallback Lock**: Uses the OmniRoute `steak` combo (Priority routing: Gemini > Claude > Llama).
- **Graceful Error Handling**: Interactive console output and pause-on-error so you can actually read what went wrong instead of the window flashing and disappearing.

## Setup
1. Edit the top variables in `ClaudeCode-OmniRoute.ps1` to match your environment (API keys, OmniRoute executable path, etc).
2. Create a Windows shortcut to `ClaudeCode-OmniRoute.cmd` and place it on your Desktop.
3. Double click the shortcut to start Claude Code.

## Files
- `ClaudeCode-OmniRoute.ps1`: The main PowerShell logic for checks and environment variables.
- `ClaudeCode-OmniRoute.cmd`: A batch wrapper that bypasses PowerShell execution policies to allow a clean double-click execution.
