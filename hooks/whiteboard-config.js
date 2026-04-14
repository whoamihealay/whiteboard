#!/usr/bin/env node
// whiteboard — shared configuration resolver
//
// Resolution order for default mode:
//   1. WHITEBOARD_DEFAULT_MODE environment variable
//   2. Config file defaultMode field:
//      - $XDG_CONFIG_HOME/whiteboard/config.json (any platform, if set)
//      - ~/.config/whiteboard/config.json (macOS / Linux fallback)
//      - %APPDATA%\whiteboard\config.json (Windows fallback)
//   3. 'on'

const fs = require('fs');
const path = require('path');
const os = require('os');

const VALID_MODES = [
  'off', 'on', 'explain', 'debug', 'design'
];

function getConfigDir() {
  if (process.env.XDG_CONFIG_HOME) {
    return path.join(process.env.XDG_CONFIG_HOME, 'whiteboard');
  }
  if (process.platform === 'win32') {
    return path.join(
      process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming'),
      'whiteboard'
    );
  }
  return path.join(os.homedir(), '.config', 'whiteboard');
}

function getConfigPath() {
  return path.join(getConfigDir(), 'config.json');
}

function getDefaultMode() {
  // 1. Environment variable (highest priority)
  const envMode = process.env.WHITEBOARD_DEFAULT_MODE;
  if (envMode && VALID_MODES.includes(envMode.toLowerCase())) {
    return envMode.toLowerCase();
  }

  // 2. Config file
  try {
    const configPath = getConfigPath();
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config.defaultMode && VALID_MODES.includes(config.defaultMode.toLowerCase())) {
      return config.defaultMode.toLowerCase();
    }
  } catch (e) {
    // Config file doesn't exist or is invalid — fall through
  }

  // 3. Default
  return 'on';
}

module.exports = { getDefaultMode, getConfigDir, getConfigPath, VALID_MODES };
