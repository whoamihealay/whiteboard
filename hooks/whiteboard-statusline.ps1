# whiteboard — statusline badge (PowerShell)
# Outputs [WHITEBOARD] badge if whiteboard mode is active.
# Add to ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"C:\\path\\to\\whiteboard-statusline.ps1\"" }

$flag = Join-Path $env:USERPROFILE ".claude\.whiteboard-active"

if (Test-Path $flag) {
    $mode = (Get-Content $flag -ErrorAction SilentlyContinue) -replace '\s',''
    if ([string]::IsNullOrEmpty($mode) -or $mode -eq "on") {
        Write-Host "[WHITEBOARD]" -ForegroundColor Cyan -NoNewline
    } else {
        Write-Host "[WHITEBOARD:$($mode.ToUpper())]" -ForegroundColor Cyan -NoNewline
    }
}
