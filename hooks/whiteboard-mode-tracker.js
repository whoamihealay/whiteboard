#!/usr/bin/env node
// whiteboard — UserPromptSubmit hook to track whiteboard mode
// Inspects user input for /whiteboard commands and writes mode to flag file

const fs = require('fs');
const path = require('path');
const os = require('os');
const { getDefaultMode } = require('./whiteboard-config');

const flagPath = path.join(os.homedir(), '.claude', '.whiteboard-active');

let input = '';
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const prompt = (data.prompt || '').trim().toLowerCase();

    // Match /whiteboard commands
    if (prompt.startsWith('/whiteboard')) {
      const parts = prompt.split(/\s+/);
      const cmd = parts[0]; // /whiteboard, /whiteboard-explain, /whiteboard-debug, /whiteboard-design

      let mode = null;

      if (cmd === '/whiteboard-explain') {
        mode = 'explain';
      } else if (cmd === '/whiteboard-debug') {
        mode = 'debug';
      } else if (cmd === '/whiteboard-design') {
        mode = 'design';
      } else if (cmd === '/whiteboard' || cmd === '/whiteboard:whiteboard') {
        mode = getDefaultMode();
      }

      if (mode && mode !== 'off') {
        fs.mkdirSync(path.dirname(flagPath), { recursive: true });
        fs.writeFileSync(flagPath, mode);
      } else if (mode === 'off') {
        try { fs.unlinkSync(flagPath); } catch (e) {}
      }
    }

    // Detect deactivation
    if (/\b(stop whiteboard|normal mode)\b/i.test(prompt)) {
      try { fs.unlinkSync(flagPath); } catch (e) {}
    }
  } catch (e) {
    // Silent fail
  }
});
