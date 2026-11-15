# PlayCanvas Responsive Scaling

PlayCanvas handles 3D world scaling natively, but UI requires specific component configurations to be truly responsive.

## 3D World (Canvas)

Ensure that in your Project Settings (or Application initialization code), the "Fill Mode" is set to `Keep Aspect Ratio` or `Fill Window`, depending on your design. The engine automatically listens to window resize events and updates the canvas resolution.

## 2D UI (Screen Component)

To make UI scale proportionally across devices:

1.  **Screen Component**: Select your 2D Screen entity.
2.  **Scale Mode**: Set to `Blend`.
3.  **Reference Resolution**: Set a logical baseline (e.g., `X: 1920, Y: 1080`).
4.  **Scale Blend**: A value of `0.5` is a good default, blending between the width and height scales.

## Anchors and Pivots

Always use Anchors on your Element components (Images, Text) so they stay pinned to the relative corners or edges of the screen, regardless of the aspect ratio.

- `Anchor: [0, 1, 0, 1]` pins an element to the Top-Left.
- `Anchor: [1, 0, 1, 0]` pins an element to the Bottom-Right.
