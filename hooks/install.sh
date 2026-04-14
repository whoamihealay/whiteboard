#!/usr/bin/env bash
# whiteboard — Claude Code hook installer
# Installs SessionStart + UserPromptSubmit hooks into ~/.claude/settings.json
# and copies hook scripts to ~/.claude/hooks/

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check node
if ! command -v node &>/dev/null; then
  echo "ERROR: node not found. Install Node.js first." >&2
  exit 1
fi

echo "Installing whiteboard hooks..."

# Create dirs
mkdir -p "$HOOKS_DIR"

# Copy hook files
HOOK_FILES=(
  whiteboard-activate.js
  whiteboard-config.js
  whiteboard-mode-tracker.js
  whiteboard-statusline.sh
  whiteboard-statusline.ps1
)

for f in "${HOOK_FILES[@]}"; do
  src="$SCRIPT_DIR/$f"
  dst="$HOOKS_DIR/$f"
  if [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "  copied $f"
  fi
done

# Copy skills dir so activate hook can read SKILL.md
SKILLS_SRC="$PLUGIN_ROOT/skills"
SKILLS_DST="$CLAUDE_DIR/whiteboard-skills"
if [ -d "$SKILLS_SRC" ]; then
  cp -r "$SKILLS_SRC" "$SKILLS_DST"
  echo "  copied skills/"
fi

# Patch settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Backup
cp "$SETTINGS" "${SETTINGS}.bak"
echo "  backed up settings.json → settings.json.bak"

# Use node to patch JSON (avoid jq dependency)
node - "$SETTINGS" "$HOOKS_DIR" <<'EOF'
const fs = require('fs');
const settingsPath = process.argv[2];
const hooksDir = process.argv[3];

let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch(e) {}

const activateCmd = `node "${hooksDir}/whiteboard-activate.js"`;
const trackerCmd = `node "${hooksDir}/whiteboard-mode-tracker.js"`;

// SessionStart hook
if (!settings.hooks) settings.hooks = {};
if (!settings.hooks.SessionStart) settings.hooks.SessionStart = [];
const hasActivate = settings.hooks.SessionStart.some(h => h.command && h.command.includes('whiteboard-activate'));
if (!hasActivate) {
  settings.hooks.SessionStart.push({
    type: 'command',
    command: activateCmd,
    timeout: 5,
    statusMessage: 'Loading whiteboard mode...'
  });
}

// UserPromptSubmit hook
if (!settings.hooks.UserPromptSubmit) settings.hooks.UserPromptSubmit = [];
const hasTracker = settings.hooks.UserPromptSubmit.some(h => h.command && h.command.includes('whiteboard-mode-tracker'));
if (!hasTracker) {
  settings.hooks.UserPromptSubmit.push({
    type: 'command',
    command: trackerCmd,
    timeout: 5,
    statusMessage: 'Tracking whiteboard mode...'
  });
}

// StatusLine — only set if not already configured
if (!settings.statusLine) {
  const isWin = process.platform === 'win32';
  const scriptName = isWin ? 'whiteboard-statusline.ps1' : 'whiteboard-statusline.sh';
  const scriptPath = `${hooksDir}/${scriptName}`;
  const command = isWin
    ? `powershell -ExecutionPolicy Bypass -File "${scriptPath}"`
    : `bash "${scriptPath}"`;
  settings.statusLine = { type: 'command', command };
  console.log('  configured statusLine badge');
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log('  patched settings.json');
EOF

echo ""
echo "Done. Whiteboard mode active on next Claude Code session."
echo "Restart Claude Code to apply."
echo ""
echo "To disable auto-start: set WHITEBOARD_DEFAULT_MODE=off"
echo "Uninstall: bash hooks/uninstall.sh"
