# Godot 4 Web Export Caveats

When deploying a Godot 4 project to the web, the internal stretch settings (configured in `project.godot`) are only half the battle. You must also configure how the HTML shell handles the `<canvas>` element inside the browser.

## 1. Canvas Resize Policy

To ensure the game physically scales as the user resizes their browser window or rotates their mobile device, configure the Export Preset:

1. Navigate to **Project > Export...**
2. Select the **Web** preset.
3. Scroll down to the **Html** section.
4. Locate **Canvas Resize Policy** and set it to **Adaptive**.

- `Adaptive`: The `<canvas>` element will automatically resize to fill the browser window. (Required for responsive web games).
- `Project`: The `<canvas>` is locked to the exact pixel dimensions specified in the Project Settings.
- `None`: The `<canvas>` is not resized by Godot, requiring manual JavaScript handling.

## 2. Rendering Method

As of Godot 4, the advanced rendering backends do not fully support WebGL/WebGPU across all browsers.

- You **must** use the **Compatibility** renderer for web exports.
- The `Forward+` and `Mobile` renderers will likely crash or fail to load in a web environment.

Ensure `rendering/renderer/rendering_method="gl_compatibility"` is set in `project.godot`.
