# Godot 4: Platform-Specific Responsiveness

While setting `canvas_items` and `expand` in your project settings creates a generic responsive foundation, each hardware platform has unique physical screen characteristics you must handle.

## 1. Desktop (Windows / macOS / Linux)

Desktop monitors vary wildly in aspect ratio, from 4:3 (legacy), 16:9 (standard), to 21:9 (Ultrawide).

- **Window Resizing:** Users expect to be able to drag to resize windowed games. Ensure `display/window/size/resizable` is set to `true` in `project.godot`.
- **Ultrawide Monitors:** Because `expand` aspect reveals more of the game world, ultrawide monitors might give players an unfair field-of-view advantage in competitive games. Consider using a script to clamp the maximum aspect ratio, falling back to black bars (letterboxing) if the screen is too wide.
- **Fullscreen Toggle:** Provide an options menu toggle or shortcut (e.g., F11 / Alt+Enter) to switch to fullscreen:
  ```gdscript
  if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
  else:
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
  ```

## 2. Mobile Native (iOS / Android)

Mobile devices have physical hardware cutouts (notches, camera punch-holes) and rounded corners that can obscure UI elements.

- **Orientation:** Decide if your game is Portrait, Landscape, or Sensor-based. Lock this in `Project > Project Settings > Display > Window > Handheld > Orientation`.
- **Safe Areas (Notches):** You must avoid placing UI inside the device's hardware cutouts. Use the OS-provided safe area rect to apply margins to your root UI container:

  ```gdscript
  func _ready():
      var safe_area = DisplayServer.get_display_safe_area()
      var window_size = DisplayServer.window_get_size()

      # Calculate margins based on the safe area
      var margin_top = safe_area.position.y
      var margin_bottom = window_size.y - (safe_area.position.y + safe_area.size.y)
      var margin_left = safe_area.position.x
      var margin_right = window_size.x - (safe_area.position.x + safe_area.size.x)

      # Apply to a root MarginContainer
      var margin_container = $UI/MarginContainer
      margin_container.add_theme_constant_override("margin_top", margin_top)
      margin_container.add_theme_constant_override("margin_bottom", margin_bottom)
      margin_container.add_theme_constant_override("margin_left", margin_left)
      margin_container.add_theme_constant_override("margin_right", margin_right)
  ```

## 3. Console (TVs)

Televisions often suffer from **Overscan**, where the physical bezel of the TV covers the outer 2-5% of the rendered image.

- **Title Safe Area:** Never place critical UI (health bars, ammo, minimaps) flush against the edge of the screen.
- **Implementation:** Always use a root `MarginContainer` for your HUD and enforce a minimum margin of roughly 5% of the screen width/height to ensure the UI is visible on all TVs.
