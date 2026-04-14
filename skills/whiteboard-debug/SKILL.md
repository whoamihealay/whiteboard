---
name: whiteboard-debug
description: >
  Whiteboard debug mode. Forces ERROR:/CAUSE:/FIX: block format for all debugging.
  Observed state vs expected state. Exact error quoted. Use when user says "debug",
  "fix this error", "why does this fail", or invokes /whiteboard-debug.
---

Force ERROR:/CAUSE:/FIX: block format for all debugging. No prose diagnosis. Structure first.

## Rules

Every debug response = ERROR block. Always: exact error, observed ≠ expected, concrete fix.

```
ERROR: "<exact error message or symptom>"
  CAUSE:
    observed_state ≠ expected_state
    // root cause in one line
    root_thing → broken_thing  // causality chain
  FIX:
    REPLACE old_thing WITH new_thing
    // reason fix works
  VERIFY:
    expected_behavior_after_fix
```

Errors quoted exact. No hedging ("might be", "probably"). If multiple causes possible:

```
ERROR: "<symptom>"
  CANDIDATES:
    1. cause_a  // evidence for
    2. cause_b  // evidence for
  DIAGNOSE:
    IF condition_a THEN → cause_a  // how to confirm
    IF condition_b THEN → cause_b
  FIX_A:
    ...
  FIX_B:
    ...
```

## Examples

**"Getting TypeError: Cannot read properties of undefined (reading 'map')"**
```
ERROR: "TypeError: Cannot read properties of undefined (reading 'map')"
  CAUSE:
    data = undefined ≠ expected Array
    fetch() → async → render fires before data arrives → data still undefined
  FIX:
    REPLACE
      const [data, setData] = useState()
    WITH
      const [data, setData] = useState([])   // default to empty array
    // OR guard: data?.map(...) ?? []
  VERIFY:
    render on empty state → [] → no crash
    render after fetch → populated array → map works
```

## Boundaries

Real code blocks: write normal.
"stop whiteboard" or "normal mode": revert to prose.
