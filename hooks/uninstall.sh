#!/usr/bin/env bash
# whiteboard — Claude Code hook uninstaller
# Removes whiteboard hooks from ~/.claude/settings.json
# and deletes hook scripts from ~/.claude/hooks/

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
FLAG="$CLAUDE_DIR/.whiteboard-active"

echo "Uninstalling whiteboard hooks..."

# Remove hook files
HOOK_FILES=(
  whiteboard-activate.js
  whiteboard-config.js
  whiteboard-mode-tracker.js
  whiteboard-statusline.sh
  whiteboard-statusline.ps1
)

for f in "${HOOK_FILES[@]}"; do
  dst="$HOOKS_DIR/$f"
  if [ -f "$dst" ]; then
    rm "$dst"
    echo "  removed $f"
  fi
done

# Remove skills copy
SKILLS_DST="$CLAUDE_DIR/whiteboard-skills"
if [ -d "$SKILLS_DST" ]; then
  rm -rf "$SKILLS_DST"
  echo "  removed whiteboard-skills/"
fi

# Remove flag file
if [ -f "$FLAG" ]; then
  rm "$FLAG"
  echo "  removed .whiteboard-active flag"
fi

# Remove backup
if [ -f "${SETTINGS}.bak" ]; then
  rm "${SETTINGS}.bak"
fi

# Patch settings.json — remove whiteboard entries
if [ -f "$SETTINGS" ] && command -v node &>/dev/null; then
  node - "$SETTINGS" <<'EOF'
const fs = require('fs');
const settingsPath = process.argv[2];

let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch(e) { process.exit(0); }

if (settings.hooks) {
  if (settings.hooks.SessionStart) {
    settings.hooks.SessionStart = settings.hooks.SessionStart.filter(
      h => !(h.command && h.command.includes('whiteboard-activate'))
    );
    if (settings.hooks.SessionStart.length === 0) delete settings.hooks.SessionStart;
  }
  if (settings.hooks.UserPromptSubmit) {
    settings.hooks.UserPromptSubmit = settings.hooks.UserPromptSubmit.filter(
      h => !(h.command && h.command.includes('whiteboard-mode-tracker'))
    );
    if (settings.hooks.UserPromptSubmit.length === 0) delete settings.hooks.UserPromptSubmit;
  }
  if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
}

// Only remove statusLine if it points to whiteboard script
if (settings.statusLine && settings.statusLine.command && settings.statusLine.command.includes('whiteboard-statusline')) {
  delete settings.statusLine;
  console.log('  removed statusLine');
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log('  patched settings.json');
EOF
fi

echo ""
echo "Done. Whiteboard hooks removed."
echo "Restart Claude Code to apply."
