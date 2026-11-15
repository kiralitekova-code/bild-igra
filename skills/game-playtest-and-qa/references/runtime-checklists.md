# Runtime Checklists

Read this file only when QA guidance needs to be runtime-specific.

## Godot

- Read logs before concluding the pass.
- Check missing input actions, node path failures, invalid resources, and collision problems.
- Check whether the issue is editor-time, build-time, or runtime.

## Phaser

- Check animation playback, spritesheet alignment, tilemap collisions, scene transitions, and input feedback.
- Call out whether likely faults sit in scene orchestration, gameplay state management, or rendering and physics wiring.

## Three.js

- Check camera behavior, overlay weight, material or lighting regressions, input transitions, and resize behavior.
- Call out likely performance cliffs tied to textures, geometry, or post-processing when visible.

## Current defaults

- Godot validation must read logs before closing the task.
- Phaser and Three.js validation should include runtime evidence and screenshots when visuals matter.
- Request a screenshot from the user if screenshots would help and no capture path exists.
