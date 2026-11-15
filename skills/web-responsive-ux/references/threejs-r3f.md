# Three.js & React Three Fiber Responsive Scaling

## Vanilla Three.js

In pure Three.js, you must manually update the Camera's aspect ratio and the Renderer's size whenever the window (or container) resizes.

```javascript
window.addEventListener('resize', () => {
  const width = window.innerWidth
  const height = window.innerHeight

  // 1. Update Renderer
  renderer.setSize(width, height)

  // 2. Update Camera
  camera.aspect = width / height
  camera.updateProjectionMatrix() // Required after changing aspect
})
```

**Crucial for Retina Displays:** Always set the pixel ratio on initialization.

```javascript
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)) // Cap at 2 for performance
```

## React Three Fiber (R3F)

React Three Fiber's `<Canvas>` component handles resizing automatically. You do not need to manually attach window resize listeners.

However, if you need to calculate logic based on the viewport size (e.g., placing an object exactly on the right edge of the screen), use the `useThree` hook:

```javascript
import { useThree } from '@react-three/fiber'

function ResponsiveObject() {
  const { viewport } = useThree()

  // Viewport provides width/height in 3D units, not pixels.
  // This positions the object on the far right edge.
  return <mesh position={[viewport.width / 2, 0, 0]} />
}
```
