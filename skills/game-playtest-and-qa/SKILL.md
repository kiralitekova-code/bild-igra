---
name: game-playtest-and-qa
displayName: Game Playtest and QA
description: Use when a game needs smoke testing, screenshot or HUD readability review, regression checks, runtime verification, or concrete gameplay and presentation findings. Do not use when the task is only authoring content, planning architecture, or writing implementation code without validation.
version: 1.0.0
metadata:
  category: Game Development
  tags:
    - game
    - qa
    - playtest
    - godot
    - phaser
    - threejs
---

# Game Playtest and QA

## Overview

Use this skill to test the game the way a player experiences it. Prefer evidence over theory: logs, screenshots, reproduction steps, and specific subsystem ownership.

## Workflow

1. Start with the evidence surface that matches the runtime.
   - Use logs, runtime checks, and screenshots according to the target stack.
   - Request a screenshot from the user if screenshots would help and no automatic capture path exists.
2. Confirm the first actionable state.
   - Verify the game reaches a usable title, menu, or gameplay screen.
3. Exercise the main verbs.
   - Move, interact, attack, navigate menus, trigger transitions, and test pause or reset behavior.
   - If movement uses WASD, verify W moves forward and S moves backward.
4. Review the presentation layer separately from the gameplay layer.
   - Check HUD weight, obstruction, readability, animation clarity, and obvious responsiveness issues.
5. Report findings in severity order.
   - Include what the player sees, how to reproduce it, why it matters, and which subsystem likely owns it.

## Reporting Standard

1. Lead with findings.
2. Keep each finding concrete.
3. Include reproduction steps.
4. State the likely owning subsystem.
5. Say when evidence is missing or incomplete.

## Do Not Do

- Do not declare the game healthy without checking the relevant log or runtime surface.
- Do not rely only on DOM assertions for canvas or WebGL-heavy games.
- Do not hide uncertainty. State when a finding is a likely cause rather than a confirmed cause.

## Assumptions

- Read `references/runtime-checklists.md` when the task needs runtime-specific QA checks or evidence expectations.
