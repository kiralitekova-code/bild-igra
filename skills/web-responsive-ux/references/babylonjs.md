# Babylon.js Responsive Scaling

Babylon.js makes handling canvas resizing straightforward via the Engine API.

## 3D World Resizing

Simply call the `engine.resize()` method inside a standard window event listener:

```javascript
window.addEventListener('resize', function () {
  engine.resize()
})
```

## GUI Resizing

Babylon's AdvancedDynamicTexture (GUI) handles rendering UI over the 3D scene. To make it responsive, you should define an "Ideal Resolution."

```javascript
import { AdvancedDynamicTexture } from '@babylonjs/gui'

const advancedTexture = AdvancedDynamicTexture.CreateFullscreenUI('UI')

// Define a logical baseline (e.g., 1080p)
advancedTexture.idealWidth = 1920
advancedTexture.idealHeight = 1080

// The UI will now scale uniformly based on the shortest axis,
// ensuring UI elements don't get squashed or stretched.
```
