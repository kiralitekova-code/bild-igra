---
name: game-engineering-foundation
displayName: Game Engineering Foundation
description: Use when shared engineering rules for Jabali game work are needed, including modularity, logs-first verification, no unsolicited UI, responsiveness, and runtime validation discipline. Do not use when the task is purely art, narrative, or audio work, or when a more specific engine skill already covers the change.
version: 1.0.0
metadata:
  category: Game Development
  tags:
    - game
    - foundation
    - validation
---

# Game Engineering Foundation

## Overview

Use this skill as the shared baseline for game engineering behavior. Apply these rules before engine-specific or content-specific tactics.

## Rules

1. Build modularly.
   - Prefer small files with one clear responsibility.
   - Split files before they become difficult to reason about.
   - Reuse existing code where possible; refactor as needed.
2. Do not create UI unless the user asks for UI.
   - Do not invent menus, HUD widgets, overlays, or settings surfaces on speculation.
   - When actionable UI appears while mouse capture is active, make the cursor visible again.
3. Keep the game responsive.
   - Preserve desktop and mobile usability where that applies.
   - Preserve layout, controls, and readability across the intended viewport range.
4. Read logs before ending an edit.
   - Use the runtime-appropriate evidence surface.
5. Validate the real integration points.
   - Check asset paths.
   - Check input mappings.
   - Check scene wiring.
   - Check runtime failures before declaring completion.

## Default Workflow

1. Read the project structure before editing.
2. Identify the runtime-specific constraints.
3. Make the smallest coherent change.
4. Validate with the relevant runtime or log surface.
   - Check related code paths for regression impact.
5. Report what was verified and what could not be verified.

## Anti-Patterns

- One giant scene or script file
- Unrequested UI expansion
- Finishing without reading logs or runtime output
- Treating placeholder asset names as stable contracts
- Ignoring runtime-specific failure surfaces
- Adding multiple ways to independently control or mutate the same state

## Assumptions

- Read `references/runtime-validation.md` when you need runtime-specific validation expectations.
