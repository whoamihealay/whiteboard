# CLAUDE.md — whiteboard

## README is a product artifact

README = product front door. Non-technical people read it to decide if whiteboard worth install. Treat like UI copy.

**Rules for any README change:**

- Readable by non-AI-agent users. Translate jargon.
- Keep Before/After examples first. That the pitch.
- Install table always complete + accurate. One broken install command costs real user.
- What You Get table must sync with actual code. Feature ships or removed → update table.
- Preserve voice. Whiteboard speak in README on purpose. "Brain think in diagram." "Word is weakness." "Box and arrow = truth." — intentional brand. Don't normalize.
- Adding new agent to install table → add detail block in `<details>` section below.
- Readability check before any README commit: would non-programmer understand + install within 60 seconds?

---

## Project overview

Whiteboard makes AI coding agents respond in pseudocode, algo notation, and diagram-style structure — zero prose, full technical accuracy. Ships as Claude Code plugin, Codex plugin, Gemini CLI extension, agent rule files for Cursor, Windsurf, Cline, Copilot, and 40+ others via `npx skills`.

---

## File structure and what owns what

### Single source of truth files — edit only these

| File | What it controls |
|------|-----------------|
| `skills/whiteboard/SKILL.md` | Whiteboard behavior: notation palette, response patterns, auto-clarity, persistence. Only file to edit for behavior changes. |
| `rules/whiteboard-activate.md` | Always-on auto-activation rule body. CI injects into Cursor, Windsurf, Cline, Copilot rule files. Edit here, not agent-specific copies. |
| `skills/whiteboard-explain/SKILL.md` | CONCEPT: block format skill. Fully independent. |
| `skills/whiteboard-debug/SKILL.md` | ERROR:/CAUSE:/FIX: block format skill. Fully independent. |
| `skills/whiteboard-design/SKILL.md` | SYSTEM: diagram format skill. Fully independent. |

### Auto-generated / auto-synced — do not edit directly

| File | Synced from |
|------|-------------|
| `whiteboard/SKILL.md` | `skills/whiteboard/SKILL.md` |
| `plugins/whiteboard/skills/whiteboard/SKILL.md` | `skills/whiteboard/SKILL.md` |
| `.cursor/skills/whiteboard/SKILL.md` | `skills/whiteboard/SKILL.md` |
| `.windsurf/skills/whiteboard/SKILL.md` | `skills/whiteboard/SKILL.md` |
| `whiteboard.skill` | ZIP of `skills/whiteboard/` directory |
| `.clinerules/whiteboard.md` | `rules/whiteboard-activate.md` |
| `.github/copilot-instructions.md` | `rules/whiteboard-activate.md` |
| `.cursor/rules/whiteboard.mdc` | `rules/whiteboard-activate.md` + Cursor frontmatter |
| `.windsurf/rules/whiteboard.md` | `rules/whiteboard-activate.md` + Windsurf frontmatter |

---

## Sub-skills

| Skill | Trigger | What it forces |
|-------|---------|---------------|
| whiteboard-explain | `/whiteboard-explain` | CONCEPT: block for all explanations |
| whiteboard-debug | `/whiteboard-debug` | ERROR:/CAUSE:/FIX: block for all debugging |
| whiteboard-design | `/whiteboard-design` | SYSTEM: diagram for all architecture |

Sub-skills specialize the active response pattern. They are independent from the core whiteboard skill — activating one does not deactivate whiteboard mode.

---

## Hooks

SessionStart hook: writes `~/.claude/.whiteboard-active`, emits whiteboard ruleset as system context.
UserPromptSubmit hook: parses `/whiteboard*` commands, writes mode to flag file. Detects "stop whiteboard" / "normal mode" and deletes flag.

Config resolution: `WHITEBOARD_DEFAULT_MODE` env var > `~/.config/whiteboard/config.json` > `'on'`.
Valid modes: `on`, `off`, `explain`, `debug`, `design`.

---

## Notation

See `skills/whiteboard/SKILL.md` for full notation palette. Core symbols:

```
→   causality, flow, return
←   assignment / input
//  comment / explanation
[X] component / box
≠ ≥ ≤   comparisons
∧ ∨ ¬   AND / OR / NOT
```
