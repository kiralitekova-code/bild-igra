---
name: web-responsive-ux
displayName: Responsive UX for Web Games
description: Use when making JavaScript or HTML5 canvas games responsive across device sizes. Do not use this skill for non-canvas web design.
version: 1.0.1
metadata:
  category: Development
  tags:
    - web
    - javascript
    - canvas
    - responsive
    - phaser
    - threejs
    - pixijs
---

# JS Web Game Responsive

This skill configures a JavaScript-based game to scale correctly in the browser. It addresses the fundamental difference between a canvas's _internal drawing resolution_ and its _CSS display size_.

## Workflow

1.  **Understand the Generic Canvas Concept**:
    - The `width` and `height` attributes on the `<canvas>` tag define the internal buffer (the pixels the engine draws to).
    - The CSS `width` and `height` properties define how large that canvas appears on the screen.
    - _Rule:_ Always scale the internal buffer to account for high-DPI displays (`window.devicePixelRatio`).

2.  **Implement CSS Container Constraints**:
    If the engine doesn't have a robust built-in scale manager, wrap the canvas in a responsive CSS container.
    - Use `aspect-ratio: X / Y` to enforce the game's shape.
    - Use `width: 100%; max-height: 100vh; object-fit: contain;` to ensure it fits the screen without overflowing.

3.  **Apply Framework-Specific Logic**:
    Look up the exact API for the framework being used. Each engine handles resize events and UI scaling differently.
    - **Phaser 3**: Review `references/phaser.md` for the Scale Manager.
    - **PlayCanvas**: Review `references/playcanvas.md` for the Screen Component and Reference Resolution.
    - **PixiJS**: Review `references/pixijs.md` for manual renderer resizing.
    - **Three.js / R3F**: Review `references/threejs-r3f.md` for Camera Aspect and Renderer sizing.
    - **Babylon.js**: Review `references/babylonjs.md` for engine resize hooks.

4.  **Implement Mobile Controls (If Applicable)**:
    If the game targets mobile devices, account for touch controls and virtual keyboards.
    - Review `references/mobile-controls.md` for strategies using hidden DOM inputs and the Visual Viewport API.

5.  **Validate Changes**:
    - Resize the browser window manually to ensure the canvas scales without distortion.
    - Verify the game looks sharp on high-DPI screens (Retina displays).
