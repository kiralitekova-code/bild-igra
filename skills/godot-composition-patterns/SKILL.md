---
name: godot-composition-patterns
displayName: Godot Composition Patterns
description: Use when a Godot project needs to be structured, refactored, or extended using scenes, reusable nodes, resources, autoloads, and signals instead of forcing an ECS architecture onto Godot. Do not use when the project is not Godot or when the task is debugging, export validation, or runtime diagnosis instead of architecture.
version: 1.0.0
metadata:
  category: Game Development
  engine: godot
  tags:
    - game
    - godot
    - architecture
    - composition
---

# Godot Composition Patterns

## Overview

Use this skill for Godot-native architecture. Prefer scene composition, reusable nodes, resources, signals, and focused autoloads instead of forcing an ECS layer into projects that do not need one.

## Workflow

1. Read the current scene tree and file structure.
   - Identify reusable scenes, singleton services (autoloads), resources, and overloaded scripts.
2. Separate responsibilities.
   - Keep scene orchestration, actor behavior, UI behavior, data resources, and global services distinct.
3. Choose the right Godot-native abstraction.
   - Scene for reusable structural content
   - Node script for local behavior
   - Resource for tunable data
   - Autoload for true cross-scene service or global state
4. Refactor by composition, not by giant inheritance chains.
5. Validate node paths, signals, and runtime wiring after changes.

## Rules

1. Keep files modular and focused.
2. Keep autoloads thin. Do not dump unrelated game state into one singleton.
3. Prefer signal-driven coordination over brittle parent or sibling assumptions.
4. Treat NodePaths as contracts that must be revalidated after structure changes.
5. Keep web-export constraints in mind when adding heavy content or blocking logic.

## Good Candidates For Resources

- stats
- upgrade data
- encounter tables
- dialogue metadata
- tunable movement or combat values

## Anti-Patterns

- one giant root scene script
- deep inheritance used to fake composition
- UI, combat, save logic, and progression all mixed into one node
- widespread hard-coded NodePaths with no validation

## Assumptions

- Godot work should follow Godot 4.x conventions.
- Jabali Studio typically edits Godot projects outside the Godot editor and often targets the browser for play.
