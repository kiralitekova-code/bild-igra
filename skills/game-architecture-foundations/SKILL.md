---
name: game-architecture-foundations
displayName: Game Architecture Foundations
description: Use when core game architecture needs to be locked before implementation, including simulation versus presentation, input model, asset and data boundaries, save and debug boundaries, performance budgets, or genre framing. Do not use when the task is pure content work or a narrow bug fix inside an existing implementation.
version: 1.0.0
metadata:
  category: Game Development
  tags:
    - game
    - architecture
    - godot
    - phaser
    - threejs
---

# Game Architecture Foundations

## Overview

Use this skill to set the non-negotiable architecture before writing core gameplay code.

## Workflow

1. Lock the structural frame.
   - Confirm the game's perspective, interaction model, and persistence model only when those choices affect architecture.
   - Ask only the questions that change scope, ownership, or system boundaries.
2. Separate simulation from presentation.
   - Simulation owns rules, state, progression, timers, collisions, and saveable data.
   - Rendering owns scene composition, animation playback, particles, camera, and visual feedback.
3. Define input as actions, not raw device reads.
   - Map actions such as `move`, `confirm`, `cancel`, `pause`, and `ability-1` in one place.
4. Define asset and data boundaries.
   - Keep assets grouped by domain.
   - Keep filenames from becoming the public gameplay API.
   - Keep tunable data external where the engine supports it well.
5. Define save, debug, and performance boundaries up front.
   - Save serializable simulation state.
   - Keep debug toggles explicit.
   - Call out the expected performance budget before content scales.
6. Hand off to the more specific skill once the structure is clear.

## Anti-Patterns

- Mixing game rules directly into rendering callbacks
- Letting asset paths or node names become hidden global contracts
- Saving renderer objects instead of gameplay state
- Rebuilding architecture every time the genre changes

## Assumptions

- Read `references/game-architecture-patterns.md` when the task needs broader structural patterns or genre framing.
