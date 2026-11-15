# JS Mobile Controls & Virtual Keyboards

Handling mobile inputs in JavaScript canvas games requires managing DOM overlays and preventing the browser's virtual keyboard from breaking your game's aspect ratio.

## Virtual Joysticks

Most HTML5 games use a DOM overlay (HTML/CSS) positioned above the `<canvas>` for virtual joysticks, or rely on framework-specific plugins.

**Example (Phaser + DOM Overlay):**
It is often more responsive to implement mobile controls as HTML elements floating above the canvas, rather than drawing them _inside_ the canvas.

1.  **HTML Setup:** Create your joystick base and knob divs.
    ```html
    <div id="ui-overlay">
      <div id="joyBase">
        <div id="joyKnob"></div>
      </div>
      <button id="btnA">Jump</button>
    </div>
    ```
2.  **CSS:** Position them using fixed or absolute positioning over the game container.
    ```css
    #ui-overlay {
      position: absolute;
      inset: 0;
      pointer-events: none; /* Let clicks pass through where there are no buttons */
    }
    #joyBase,
    #btnA {
      pointer-events: auto;
    }
    ```
3.  **JavaScript Integration:** Listen to `touchstart` and `touchmove` events on the DOM elements, calculate the normalized axis (-1 to 1), and dispatch a custom event to your game logic.

    ```javascript
    // Example extracting axis from touch move
    const onMove = (e) => {
      const touch = e.touches[0]
      // ... calculate dx/dy from joystick center ...
      const len = Math.hypot(dx, dy)
      if (len === 0) {
        window.dispatchEvent(new CustomEvent('joystick:move', { detail: { x: 0, y: 0 } }))
        return
      }

      const clampedLen = Math.min(len, MAX_RADIUS)

      // Normalize to -1.0 -> 1.0
      const inv = 1 / len
      const axisX = dx * inv * (clampedLen / MAX_RADIUS)
      const axisY = dy * inv * (clampedLen / MAX_RADIUS)

      // Dispatch to game
      window.dispatchEvent(new CustomEvent('joystick:move', { detail: { x: axisX, y: axisY } }))
    }
    ```

## Virtual Keyboards & Visual Viewport API

A common issue in mobile web games is the virtual keyboard triggering a `window.resize` event, which can squish or distort your `<canvas>`.

### 1. Prevent Canvas Resizing

Use the `interactive-widget` property in your HTML `<meta>` viewport tag to tell the browser _not_ to resize the layout viewport when the keyboard opens:

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0, interactive-widget=resizes-visual"
/>
```

### 2. Triggering the Keyboard

Canvas elements cannot trigger keyboards natively. You must use a hidden, focusable DOM element (like an `<input>` or `<textarea>`).

```javascript
const hiddenInput = document.createElement('input')
hiddenInput.type = 'text'
hiddenInput.style.position = 'absolute'
hiddenInput.style.opacity = '0' // Hide it, but keep it focusable
document.body.appendChild(hiddenInput)

// When the user taps a button in your game:
myGameButton.on('pointerdown', () => {
  hiddenInput.focus()
})
```

### 3. Repositioning UI (Visual Viewport API)

Because the keyboard covers the bottom of the screen without resizing the layout, you must move your DOM-based UI elements (like a chat box) up manually using the Visual Viewport API.

```javascript
if (window.visualViewport) {
  window.visualViewport.addEventListener('resize', () => {
    const vv = window.visualViewport
    const uiElement = document.getElementById('my-game-ui')

    // Calculate how much of the screen is covered
    const keyboardHeight = window.innerHeight - vv.height

    // Push the UI up above the keyboard
    uiElement.style.bottom = `${keyboardHeight}px`
  })
}
```
