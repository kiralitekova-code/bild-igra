---
name: godot-debugging-and-log-reading
displayName: Godot Debugging and Log Reading
description: Use when a Godot project needs diagnosis by reading logs first, classifying failures, tracing broken node or resource wiring, and verifying runtime, build, or export errors before editing. Do not use when the task is architecture planning, gameplay design, or content creation rather than diagnosis.
version: 1.0.0
metadata:
  category: Game Development
  engine: godot
  tags:
    - game
    - godot
    - debugging
    - logs
---

# Godot Debugging and Log Reading

## Overview

Use this skill when Godot work is failing or suspicious. Start with logs, not guesses. Classify the failure, trace it to the likely subsystem, then validate the fix against the same evidence surface.

## Workflow

1. Read the logs first.
   - Determine whether the problem is build-time, runtime, or export-time.
2. Classify the failure.
   - node path failure
   - missing input action
   - collision or physics setup failure
   - invalid resource path
   - wrong process-loop usage
   - script or syntax failure
   - referencing a non-existent variable or function
3. Trace the owning subsystem.
   - scene wiring
   - script logic
   - project settings
   - resource setup
   - export configuration
4. Fix the smallest coherent root cause.
5. Re-check the relevant evidence surface.
   - Do not stop after only editing the file.

## Common Failure Classes

### Node and scene wiring

- stale NodePaths
- renamed or moved nodes
- missing child nodes expected by scripts

### Input

- missing input actions
- mismatch between code and project settings action names
- mismatch between `.gd` scripts and the input actions defined in `project.godot`

### Collision and physics

- missing `CollisionShape2D` or `CollisionShape3D` child on the relevant physics body
- wrong node type for physics usage
- movement logic in the wrong process loop

### Resources and paths

- bad `res://` path
- stale asset or scene references
- invalid external dependency assumptions

## Output Standard

1. State what the logs show.
2. State the likely root cause.
3. State the fix or next verification step.
4. State whether the post-fix evidence cleared the issue.

## Assumptions

- Godot logs, build errors, and runtime diagnostics are mandatory evidence surfaces.
- Common failure classes include stale NodePaths, missing input actions, collision setup mistakes, bad resource paths, and wrong process-loop usage.
