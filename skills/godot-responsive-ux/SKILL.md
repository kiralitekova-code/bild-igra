---
name: godot-responsive-ux
displayName: Godot Responsive UI
description: Use when configuring Godot 4 project settings and UI nodes to scale responsively across desktop, mobile, console, or web targets. Do not use this skill for 3D camera logic or physics scaling.
version: 1.0.2
metadata:
  category: Development
  tags:
    - godot
    - ui
    - responsive
    - scaling
    - cross-platform
---

# Godot Responsive UI

This skill configures a Godot 4 project to handle arbitrary screen resolutions and aspect ratios gracefully. It covers global project stretch settings and node-level UI anchoring.

## Workflow

1.  **Configure Project Stretch Settings**:
    Open `Project > Project Settings > Display > Window > Stretch` and apply the following:
    - **Mode**: Set to `canvas_items`. This ensures the 2D environment and UI scale with the window while maintaining crisp, native-resolution rendering. (Use `viewport` _only_ if the project explicitly requires pixel-perfect retro scaling).
    - **Aspect**: Set to `expand`. This allows the game to fill wider or taller screens without distorting the art, revealing more of the game world. (Use `keep` _only_ if you want forced letterboxing/black bars).

2.  **Implement UI Anchoring**:
    Because the `expand` aspect ratio changes the visible screen boundaries, UI elements cannot rely on fixed pixel positions.
    - Use **Control Nodes** (e.g., `MarginContainer`, `VBoxContainer`, `HBoxContainer`) for all UI.
    - Set the **Anchors** of parent UI containers to pin them to the edges of the screen (e.g., Full Rect, Top Wide, Bottom Right).
    - Ensure child UI elements use appropriate **Size Flags** (Expand, Fill) to distribute space correctly within their containers.

3.  **Handle Platform-Specific Hardware Constraints**:
    Each platform has physical differences (Ultrawide monitors, mobile notches, TV overscan).
    - Review `references/platform-specifics.md` for handling safe areas, fullscreen toggling, and aspect-ratio clamping.

4.  **Check for Web Export Requirements**:
    If the project is intended to be exported to the Web (HTML5), there are additional critical requirements.
    - Review `references/web-export.md` for specific Web Export configurations.

5.  **Implement Mobile Controls (If Applicable)**:
    If the game targets mobile devices, account for touch controls and virtual keyboards.
    - Review `references/mobile-controls.md` for strategies on touch nodes and avoiding virtual keyboard overlap.

6.  **Validate Changes**:
    - Verify the changes to `project.godot` (specifically `display/window/stretch/mode` and `display/window/stretch/aspect`).
    - If UI nodes were modified, verify their Anchor presets in the corresponding `.tscn` files.
