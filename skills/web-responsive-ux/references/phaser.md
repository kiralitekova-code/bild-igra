# Phaser 3 Responsive Scaling

Phaser 3 has a robust built-in Scale Manager that handles most responsive behavior automatically. You rarely need to touch the DOM or CSS directly.

## Configuration

In the main Game Config object, define the `scale` property:

```javascript
const config = {
  type: Phaser.AUTO,
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width: 1920,
    height: 1080,
  },
  // ...
}
```

### Scale Modes

- `Phaser.Scale.FIT`: Scales the canvas up or down to fit inside the parent container while maintaining the aspect ratio defined by `width` and `height`. (Highly recommended).
- `Phaser.Scale.RESIZE`: The canvas matches the exact size of the parent container. The aspect ratio will change. You must reposition UI elements manually in a `resize` listener.

## UI Positioning

Do not use hardcoded pixel values (e.g., `x: 1800`) if there is any chance the aspect ratio might change.

Instead, calculate positions based on the game's actual configuration size:

```javascript
// Good practice
const { width, height } = this.sys.game.config
const healthBar = this.add.image(width * 0.05, height * 0.05, 'health')
```
