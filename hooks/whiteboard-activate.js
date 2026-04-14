#!/usr/bin/env node
// whiteboard — Claude Code SessionStart activation hook
//
// Runs on every session start:
//   1. Writes flag file at ~/.claude/.whiteboard-active (statusline reads this)
//   2. Emits whiteboard ruleset as hidden SessionStart context
//   3. Detects missing statusline config and emits setup nudge

const fs = require('fs');
const path = require('path');
const os = require('os');
const { getDefaultMode } = require('./whiteboard-config');

const claudeDir = path.join(os.homedir(), '.claude');
const flagPath = path.join(claudeDir, '.whiteboard-active');
const settingsPath = path.join(claudeDir, 'settings.json');

const mode = getDefaultMode();

// "off" mode — skip activation entirely, don't write flag or emit rules
if (mode === 'off') {
  try { fs.unlinkSync(flagPath); } catch (e) {}
  process.stdout.write('OK');
  process.exit(0);
}

// 1. Write flag file
try {
  fs.mkdirSync(path.dirname(flagPath), { recursive: true });
  fs.writeFileSync(flagPath, mode);
} catch (e) {
  // Silent fail -- flag is best-effort, don't block the hook
}

// 2. Emit full whiteboard ruleset.
//    Full rules with examples anchor behavior much more reliably than a summary.
//    Reads SKILL.md at runtime so edits to the source of truth propagate
//    automatically — no hardcoded duplication to go stale.

// Sub-skills that have their own independent skill files.
// For these, emit a short activation line; the skill itself handles behavior.
const INDEPENDENT_MODES = new Set(['explain', 'debug', 'design']);

if (INDEPENDENT_MODES.has(mode)) {
  process.stdout.write('WHITEBOARD MODE ACTIVE — sub-skill: ' + mode + '. Behavior defined by /whiteboard-' + mode + ' skill.');
  process.exit(0);
}

// Read SKILL.md — the single source of truth for whiteboard behavior.
// Plugin installs: __dirname = <plugin_root>/hooks/, SKILL.md at <plugin_root>/skills/whiteboard/SKILL.md
// Standalone installs: __dirname = ~/.claude/hooks/, SKILL.md won't exist — falls back to hardcoded rules.
let skillContent = '';
try {
  skillContent = fs.readFileSync(
    path.join(__dirname, '..', 'skills', 'whiteboard', 'SKILL.md'), 'utf8'
  );
} catch (e) { /* standalone install — will use fallback below */ }

let output;

if (skillContent) {
  // Strip YAML frontmatter
  const body = skillContent.replace(/^---[\s\S]*?---\s*/, '');
  output = 'WHITEBOARD MODE ACTIVE\n\n' + body;
} else {
  // Fallback when SKILL.md is not found (standalone hook install without skills dir).
  output =
    'WHITEBOARD MODE ACTIVE\n\n' +
    'All responses as whiteboard pseudocode. No prose. Technical substance exact.\n\n' +
    '## Persistence\n\n' +
    'ACTIVE EVERY RESPONSE. No revert after many turns. No prose drift. Still active if unsure. Off only: "stop whiteboard" / "normal mode".\n\n' +
    '## Rules\n\n' +
    '- Every response = pseudocode, algo steps, or diagram notation\n' +
    '- No prose sentences — encode all meaning as pseudocode constructs\n' +
    '- Indentation = scope\n' +
    '- `//` for comments and explanations\n' +
    '- `→` for causality / flow / return\n' +
    '- Real code blocks unchanged\n' +
    '- Technical terms exact, never paraphrased\n\n' +
    '## Boundaries\n\n' +
    'Real code blocks: write normal. Commits/PRs: write normal. "stop whiteboard" or "normal mode": revert.';
}

// 3. Detect missing statusline config — nudge Claude to help set it up
try {
  let hasStatusline = false;
  if (fs.existsSync(settingsPath)) {
    const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    if (settings.statusLine) {
      hasStatusline = true;
    }
  }

  if (!hasStatusline) {
    const isWindows = process.platform === 'win32';
    const scriptName = isWindows ? 'whiteboard-statusline.ps1' : 'whiteboard-statusline.sh';
    const scriptPath = path.join(__dirname, scriptName);
    const command = isWindows
      ? `powershell -ExecutionPolicy Bypass -File "${scriptPath}"`
      : `bash "${scriptPath}"`;
    const statusLineSnippet =
      '"statusLine": { "type": "command", "command": ' + JSON.stringify(command) + ' }';
    output += "\n\n" +
      "STATUSLINE SETUP NEEDED: The whiteboard plugin includes a statusline badge showing active mode " +
      "([WHITEBOARD]). It is not configured yet. " +
      "To enable, add this to ~/.claude/settings.json: " +
      statusLineSnippet + " " +
      "Proactively offer to set this up for the user on first interaction.";
  }
} catch (e) {
  // Silent fail — don't block session start over statusline detection
}

process.stdout.write(output);
