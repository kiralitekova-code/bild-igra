---
name: consistent-character-asset-generation
displayName: Consistent Character Asset Generation
description: Use when repeatable character portraits, full-body renders, turnarounds, or outfit and expression variants must stay visually consistent across a game asset set. Do not use when generating one-off concept art, non-character assets, environments, props, or implementation-only character behavior.
version: 1.0.1
metadata:
  category: Game Development
  tags:
    - game
    - character
    - assets
    - art
---

# Consistent Character Asset Generation

## Overview

Use this skill for repeatable character sets, not one-off concept art. The goal is a stable production spec that survives multiple poses, expressions, outfits, and camera angles.

## Workflow

1. Define a canonical character spec first.
   - Lock silhouette, height, body proportions, palette family, hairstyle, costume anchors, and defining accessories.
   - Record the intended use: portrait, full body, turnaround, sprite seed frame, or marketing image.
2. Approve a stable base representation.
   - Prefer one approved portrait or full-body view before generating variants.
3. Generate variants from the locked spec.
   - Keep expressions, outfits, and turnarounds tied to the same base identity.
   - Keep orientation requests explicit.
4. Review consistency before approval.
   - Check face shape, palette drift, costume drift, limb proportions, and accessory placement.
5. Package outputs for downstream use.
   - Note how the asset will feed the target runtime or content pipeline.

## Prompt Invariants

Always preserve:

- same character
- same silhouette family
- same palette family
- same outfit proportions
- same face identity
- same defining accessories
- same age read and body scale

## Jabali-Specific Guidance

1. Treat character generation as a constrained production pipeline.
   - Start from one approved portrait or full-body base.
   - Keep orientation variants explicit: front, left, right, or turnaround sets.
   - Prefer stable variant generation over exploratory redraws once approval exists.
2. Prefer cached or previously approved assets when consistency matters more than novelty.
3. Treat the approved base asset as a production contract.

## Assumptions

- Treat approved character assets as production contracts for later spritesheet or dialogue use.
- Read `references/runtime-consumption.md` when the task needs runtime-specific packaging notes.
