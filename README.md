<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/memo_1f4dd.png" width="120" />
</p>

<h1 align="center">whiteboard</h1>

<p align="center">
  <strong>why use word when box do trick</strong>
</p>

<p align="center">
  <a href="https://github.com/whoamihealay/whiteboard/stargazers"><img src="https://img.shields.io/github/stars/whoamihealay/whiteboard?style=flat&color=blue" alt="Stars"></a>
  <a href="https://github.com/whoamihealay/whiteboard/commits/main"><img src="https://img.shields.io/github/last-commit/whoamihealay/whiteboard?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/whoamihealay/whiteboard?style=flat" alt="License"></a>
</p>

<p align="center">
  <a href="#before--after">Before/After</a> •
  <a href="#install">Install</a> •
  <a href="#whiteboard-skills">Skills</a> •
  <a href="#notation">Notation</a>
</p>

---

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill/plugin that makes agent respond in pseudocode, algo notation, and diagram-style structure — **zero prose, full technical accuracy**. Also has [whiteboard-explain](#whiteboard-explain), [whiteboard-debug](#whiteboard-debug), and [whiteboard-design](#whiteboard-design) for forcing specific block formats.

Brain think in diagram. Word is weakness. Box and arrow = truth.

Inspired (and mostly copied) by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

## Before / After

<table>
<tr>
<td width="50%">

### 🗣️ Normal Claude

> "The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object."

</td>
<td width="50%">

### 📋 Whiteboard Claude

```
FUNCTION render(props)
  // inline object prop → new ref each call
  IF prev_ref ≠ curr_ref THEN
    TRIGGER re-render
// FIX:
  value ← useMemo(() → expensiveObj, [deps])
```

</td>
</tr>
<tr>
<td>

### 🗣️ Normal Claude

> "I'd be happy to help design your auth system. You'll want to think about JWTs for stateless authentication — the server signs a token with a secret key, the client stores it and sends it with each request, and the server verifies it. You should also consider refresh tokens for longer sessions."

</td>
<td>

### 📋 Whiteboard Claude

```
SYSTEM: JWT Auth
  [Client] → POST /login {user, pass} → [Server]
  [Server]:
    IF verify(user, pass) THEN
      token ← sign({userId, exp}, SECRET)
      RETURN token
    ELSE
      THROW 401
  [Client] → GET /api + Bearer token → [Server]
  [Server]: verify(token) → resource | 401
```

</td>
</tr>
</table>

**Same answer. Zero word. All structure. Draw once. Understand forever.**

```
┌─────────────────────────────────────────┐
│  PROSE REMOVED         ████████████ 100%│
│  TECHNICAL ACCURACY    ████████████ 100%│
│  AMBIGUITY             ░░░░░░░░░░░░   0%│
│  BOXES                 ████████████  MAX│
└─────────────────────────────────────────┘
```

- **Zero ambiguity** — structure forces precision, prose hides vagueness
- **Faster comprehension** — diagram faster to parse than paragraph
- **Same accuracy** — all technical info kept, zero fluff
- **Great for architecture** — boxes and arrows beat wall of text every time
- **Fun** — every debug session become flowchart

## Install

Pick agent. One command. Done.

| Agent           | Install                                                                                                |
| --------------- | ------------------------------------------------------------------------------------------------------ |
| **Claude Code** | `claude plugin marketplace add whoamihealay/whiteboard && claude plugin install whiteboard@whiteboard` |
| **Codex**       | Clone repo → `/plugins` → Search "Whiteboard" → Install                                                |
| **Gemini CLI**  | `gemini extensions install https://github.com/whoamihealay/whiteboard`                                 |
| **Cursor**      | `npx skills add whoamihealay/whiteboard -a cursor`                                                     |
| **Windsurf**    | `npx skills add whoamihealay/whiteboard -a windsurf`                                                   |
| **Copilot**     | `npx skills add whoamihealay/whiteboard -a github-copilot`                                             |
| **Cline**       | `npx skills add whoamihealay/whiteboard -a cline`                                                      |
| **Any other**   | `npx skills add whoamihealay/whiteboard`                                                               |

Install once. Box appear every session. Draw forever.

### What You Get

| Feature                     | Claude Code | Codex | Gemini CLI | Cursor | Windsurf | Cline | Copilot |
| --------------------------- | :---------: | :---: | :--------: | :----: | :------: | :---: | :-----: |
| Whiteboard mode             |      Y      |   Y   |     Y      |   Y    |    Y     |   Y   |    Y    |
| Auto-activate every session |      Y      |  Y¹   |     Y      |   —²   |    —²    |  —²   |   —²    |
| `/whiteboard` command       |      Y      |  Y¹   |     Y      |   —    |    —     |   —   |    —    |
| Statusline badge            |     Y³      |   —   |     —      |   —    |    —     |   —   |    —    |
| whiteboard-explain          |      Y      |   —   |     Y      |   Y    |    Y     |   Y   |    Y    |
| whiteboard-debug            |      Y      |   —   |     Y      |   Y    |    Y     |   Y   |    Y    |
| whiteboard-design           |      Y      |   —   |     Y      |   Y    |    Y     |   Y   |    Y    |

> ¹ Codex uses `$whiteboard` syntax. This repo ships `.codex/hooks.json`, so whiteboard auto-starts inside this repo.
> ² Add the "Want it always on?" snippet below for auto-start in other agents.
> ³ Shows `[WHITEBOARD]` badge. Plugin install nudges setup on first session.

<details>
<summary><strong>Claude Code — full details</strong></summary>

```bash
claude plugin marketplace add whoamihealay/whiteboard
claude plugin install whiteboard@whiteboard
```

**Standalone hooks (without plugin):**

```bash
# macOS / Linux / WSL
bash <(curl -s https://raw.githubusercontent.com/whoamihealay/whiteboard/main/hooks/install.sh)

# from local clone
bash hooks/install.sh
```

Uninstall: `bash hooks/uninstall.sh`

</details>

<details>
<summary><strong>Cursor / Windsurf / Cline / Copilot — full details</strong></summary>

`npx skills add` installs the skill file only — whiteboard does not auto-start. For always-on, add the "Want it always on?" snippet to your agent's rules.

| Agent    | Command                                                    | Always-on location           |
| -------- | ---------------------------------------------------------- | ---------------------------- |
| Cursor   | `npx skills add whoamihealay/whiteboard -a cursor`         | Cursor rules                 |
| Windsurf | `npx skills add whoamihealay/whiteboard -a windsurf`       | Windsurf rules               |
| Cline    | `npx skills add whoamihealay/whiteboard -a cline`          | Cline rules or system prompt |
| Copilot  | `npx skills add whoamihealay/whiteboard -a github-copilot` | Copilot custom instructions  |

Uninstall: `npx skills remove whiteboard`

</details>

<details>
<summary><strong>Any other agent (opencode, Roo, Amp, Goose, Kiro, and 40+ more)</strong></summary>

```bash
npx skills add whoamihealay/whiteboard           # auto-detect agent
npx skills add whoamihealay/whiteboard -a amp
npx skills add whoamihealay/whiteboard -a goose
npx skills add whoamihealay/whiteboard -a roo
```

**Want it always on?** Paste into agent's system prompt or rules file:

```
All responses as whiteboard pseudocode. No prose. Technical substance exact.
Every response = pseudocode, algo steps, or diagram notation.
Indentation = scope. // for comments. → for causality/flow.
Real code blocks unchanged. Technical terms exact.
ACTIVE EVERY RESPONSE. Off: "stop whiteboard" / "normal mode".
Code/commits/PRs: normal.
```

Where to put it:
| Agent | File |
|-------|------|
| opencode | `.config/opencode/AGENTS.md` |
| Roo | `.roo/rules/whiteboard.md` |
| Amp | your workspace system prompt |
| Others | your agent's system prompt or rules file |

</details>

## Usage

Activate:

- `/whiteboard`
- "whiteboard mode"
- "pseudocode"
- "talk like whiteboard"

Stop: "stop whiteboard" or "normal mode"

## Whiteboard Skills

| Skill                  | What it force                                                             | Trigger               |
| ---------------------- | ------------------------------------------------------------------------- | --------------------- |
| **whiteboard-explain** | CONCEPT: block — components, flow, tradeoffs                              | `/whiteboard-explain` |
| **whiteboard-debug**   | ERROR:/CAUSE:/FIX: block — exact error, observed ≠ expected, concrete fix | `/whiteboard-debug`   |
| **whiteboard-design**  | SYSTEM: diagram — boxes, arrows, data flows, tradeoffs                    | `/whiteboard-design`  |

### whiteboard-explain

Force CONCEPT: block format for any explanation.

```
CONCEPT: useEffect(fn, deps)
  // run side effects after render, optionally on dep changes
  COMPONENTS:
    - fn      // effect function, optionally returns cleanup
    - deps    // array; effect re-runs when any changes
    - cleanup // returned fn; runs before next effect or unmount
  FLOW:
    render → commit DOM → run effect(s)
    deps change → cleanup previous → run effect again
  TRADEOFF:
    + declarative side-effect lifecycle
    - empty deps [] = stale closure trap
  WHEN TO USE:
    external subscription / fetch / timer → useEffect
    pure derived value → useMemo instead
```

### whiteboard-debug

Force ERROR:/CAUSE:/FIX: block for every bug.

```
ERROR: "TypeError: Cannot read properties of undefined (reading 'map')"
  CAUSE:
    data = undefined ≠ expected Array
    fetch() async → render fires before data arrives → data still undefined
  FIX:
    REPLACE useState() WITH useState([])   // default to empty array
  VERIFY:
    render on empty state → [] → no crash
    render after fetch → populated array → map works
```

### whiteboard-design

Force SYSTEM: diagram for every architecture question.

```
SYSTEM: ConnectionPool
  pool ← [conn1, conn2, ..., connN]  // pre-opened

  FUNCTION acquire() → Connection
    IF pool.hasIdle() THEN
      RETURN pool.checkout()         // reuse, skip handshake
    ELSE IF pool.size < MAX THEN
      RETURN pool.openNew()
    ELSE
      WAIT until idle

  FUNCTION release(conn)
    pool.checkin(conn)               // back, not closed

  TRADEOFF:
    + skip TCP+auth handshake per request → fast under load
    - pool size must be tuned; too small = bottleneck
```

## Notation

Full reference in [skills/whiteboard/SKILL.md](skills/whiteboard/SKILL.md).

```
FUNCTION name(params) → returnType
IF condition THEN ... ELSE ...
FOR each item IN collection DO ...
WHILE condition DO ...
RETURN value
THROW error
// comment / explanation
→   causality, flow, returns
←   assignment or input
≠   not equal
≥ ≤ > <  comparisons
∧ ∨ ¬   AND / OR / NOT
[A, B, C]  list
{k: v}   map/object
[Box]    component / system node
A | B    union / or-type
```

**Auto-Clarity:** Whiteboard drops pseudocode for security warnings, irreversible action confirmations, and when user is confused. Resumes after clear part done.

## Star This Repo

If whiteboard make your answer cleaner, your design clearer — leave star. ⭐

## License

MIT — free like blank whiteboard. Draw anything.
