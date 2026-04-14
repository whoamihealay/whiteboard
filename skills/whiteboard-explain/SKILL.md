---
name: whiteboard-explain
description: >
  Whiteboard explanation mode. Forces CONCEPT: block format for any explanation —
  components, flow, tradeoffs. Use when user says "explain", "what is", "how does X work",
  or invokes /whiteboard-explain. Auto-triggers for concept explanations in whiteboard mode.
---

Force CONCEPT: block format for all explanations. No prose. Structure first.

## Rules

Every explanation = CONCEPT block. Always include: what it is, components, flow, tradeoffs.

```
CONCEPT: <name>
  // one-line definition
  COMPONENTS:
    - part1  // role
    - part2  // role
  FLOW:
    input → transform → output
  TRADEOFF:
    + benefit
    - cost
  WHEN TO USE:
    condition → use this
    condition → avoid this
```

Technical terms exact. No paraphrasing. Code inline where it clarifies.

## Examples

**"Explain React useEffect"**
```
CONCEPT: useEffect(fn, deps)
  // run side effects after render, optionally on dep changes
  COMPONENTS:
    - fn        // effect function, optionally returns cleanup
    - deps      // array of values; effect re-runs when any changes
    - cleanup   // returned fn from effect; runs before next effect or unmount
  FLOW:
    render → commit DOM → run effect(s)
    deps change → cleanup previous → run effect again
    unmount → cleanup
  TRADEOFF:
    + declarative side-effect lifecycle
    - empty deps [] = run once (common mistake: stale closure)
    - missing dep = stale value bug
  WHEN TO USE:
    external subscription / fetch / timer → useEffect
    pure derived value → useMemo instead
    no side effects needed → no useEffect
```

## Boundaries

Real code blocks: write normal.
"stop whiteboard" or "normal mode": revert to prose.
