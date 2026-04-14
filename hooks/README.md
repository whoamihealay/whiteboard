# whiteboard hooks

Claude Code SessionStart and UserPromptSubmit hooks for whiteboard mode.

## Install

```bash
# macOS / Linux / WSL
bash <(curl -s https://raw.githubusercontent.com/whoamihealay/whiteboard/main/hooks/install.sh)

# from local clone
bash hooks/install.sh
```

## Uninstall

```bash
bash hooks/uninstall.sh
```

## What gets installed

| File                         | Location           | Purpose                                                        |
| ---------------------------- | ------------------ | -------------------------------------------------------------- |
| `whiteboard-activate.js`     | `~/.claude/hooks/` | SessionStart hook — emits whiteboard ruleset as system context |
| `whiteboard-config.js`       | `~/.claude/hooks/` | Shared config resolver — reads env var / config file           |
| `whiteboard-mode-tracker.js` | `~/.claude/hooks/` | UserPromptSubmit hook — tracks `/whiteboard*` commands         |
| `whiteboard-statusline.sh`   | `~/.claude/hooks/` | Outputs `[WHITEBOARD]` badge for statusLine config             |
| `whiteboard-statusline.ps1`  | `~/.claude/hooks/` | PowerShell equivalent                                          |

## Configure default mode

Default = `on` (whiteboard active every session). Change it:

**Environment variable:**

```bash
export WHITEBOARD_DEFAULT_MODE=off
```

**Config file** (`~/.config/whiteboard/config.json`):

```json
{ "defaultMode": "off" }
```

Valid modes: `on`, `off`, `explain`, `debug`, `design`

Set `"off"` to disable auto-activation. User can still activate manually with `/whiteboard`.

## Statusline badge

Shows `[WHITEBOARD]` or `[WHITEBOARD:DEBUG]` in the Claude Code status bar.

The installer configures this automatically if no custom `statusLine` is already set.

To add manually, put in `~/.claude/settings.json`:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"/path/to/whiteboard-statusline.sh\""
}
```

## Custom statusline

If you already have a custom `statusLine`, the installer leaves it alone. To merge:

```json
"statusLine": {
  "type": "command",
  "command": "echo \"$(bash ~/.claude/hooks/whiteboard-statusline.sh) $(your-existing-command)\""
}
```
