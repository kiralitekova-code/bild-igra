# PixiJS Responsive Scaling

PixiJS is a low-level rendering engine and does not provide an automated "scale manager." You must handle responsiveness manually using CSS and JavaScript resize events.

## CSS Strategy (Recommended)

The easiest approach for fixed aspect-ratio games in PixiJS is to let CSS handle the physical scaling, while PixiJS handles the internal resolution rendering.

```css
canvas {
  /* Define logical ratio */
  aspect-ratio: 16 / 9;
  width: 100%;
  max-height: 100vh;
  object-fit: contain; /* Letterboxing */
}
```

## JavaScript Resize Hooks

If you need a "Full Bleed" game (where the canvas aspect ratio changes to match the screen exactly), you must hook into the window resize event and manually update the renderer.

```javascript
const app = new PIXI.Application({
  resizeTo: window, // Automatically resizes renderer to window
  resolution: window.devicePixelRatio || 1,
  autoDensity: true, // Vital for crisp text/sprites on Retina displays
})

window.addEventListener('resize', () => {
  // Re-calculate UI positions based on new app.screen.width / app.screen.height
  myMenuContainer.position.set(app.screen.width / 2, app.screen.height / 2)
})
```
