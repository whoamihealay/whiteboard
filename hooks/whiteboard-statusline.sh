#!/usr/bin/env bash
# whiteboard — statusline badge
# Outputs [WHITEBOARD] badge if whiteboard mode is active.
# Add to ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash \"/path/to/whiteboard-statusline.sh\"" }

FLAG="$HOME/.claude/.whiteboard-active"

if [ -f "$FLAG" ]; then
  MODE=$(cat "$FLAG" 2>/dev/null || echo "on")
  if [ "$MODE" = "on" ] || [ "$MODE" = "" ]; then
    printf '\033[36m[WHITEBOARD]\033[0m'
  else
    printf '\033[36m[WHITEBOARD:%s]\033[0m' "$(echo "$MODE" | tr '[:lower:]' '[:upper:]')"
  fi
fi
