---
name: whiteboard-design
description: >
  Whiteboard architecture/design mode. Forces SYSTEM: diagram format for all architecture
  and design discussions — boxes, arrows, data flows, tradeoffs. Use when user says
  "design", "architecture", "how should I structure", or invokes /whiteboard-design.
---

Force SYSTEM: diagram format for all architecture and design. No prose. Boxes and arrows only.

## Rules

Every design response = SYSTEM block. Boxes = components `[Name]`. Arrows = data/control flow `→`.

```
SYSTEM: <name>
  // one-line purpose
  COMPONENTS:
    [ComponentA]  // role
    [ComponentB]  // role
  FLOW:
    [A] → request  → [B]
    [B] → query    → [DB]
    [B] → response → [A]
  TRADEOFF:
    + what this design makes easy
    - what it makes hard
  ALTERNATIVES:
    alt_approach → USE WHEN: condition
```

Arrows carry payload: `[A] → {userId, token} → [B]`
Async flows: `[A] → emit(event) → [Queue] ← consume ← [Worker]`
Failure paths: `[B] → THROW 503 → [A]  // if DB down`

## Examples

**"Design a user auth system"**
```
SYSTEM: UserAuth
  COMPONENTS:
    [Client]      // browser / mobile app
    [AuthService] // stateless JWT issuer
    [UserDB]      // users + hashed passwords
    [TokenStore]  // Redis — refresh token blacklist

  FLOW: Login
    [Client] → POST /auth/login {email, pass} → [AuthService]
    [AuthService] → SELECT user WHERE email → [UserDB]
    [AuthService]:
      IF bcrypt.verify(pass, hash) THEN
        accessToken  ← sign({userId, role}, SECRET, exp=15m)
        refreshToken ← sign({userId}, REFRESH_SECRET, exp=7d)
        RETURN {accessToken, refreshToken}
      ELSE
        THROW 401

  FLOW: Authenticated Request
    [Client] → GET /api/data + Bearer accessToken → [AuthService]
    [AuthService]:
      payload ← verify(accessToken, SECRET)  // throws if expired
      RETURN data

  FLOW: Token Refresh
    [Client] → POST /auth/refresh {refreshToken} → [AuthService]
    [AuthService]:
      IF TokenStore.isBlacklisted(refreshToken) THEN THROW 401
      payload ← verify(refreshToken, REFRESH_SECRET)
      RETURN new accessToken

  TRADEOFF:
    + stateless access tokens → no DB hit per request
    - 15m window where revoked access token still valid
    - refresh token blacklist → Redis required
  ALTERNATIVES:
    session cookies → USE WHEN: SSR only, no mobile client
    opaque tokens  → USE WHEN: must revoke instantly
```

## Boundaries

Real code blocks: write normal.
"stop whiteboard" or "normal mode": revert to prose.
