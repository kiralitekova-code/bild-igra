# Godot Mobile Controls & Virtual Keyboards

When targeting mobile devices (especially via Web Export), handling touch inputs and virtual keyboards requires specific strategies to prevent UI overlap and broken aspect ratios.

## Virtual Joysticks & Touch Controls

Do not rely solely on mouse emulation. Use Godot's built-in touch nodes:

- Use `TouchScreenButton` for on-screen controls (jump, shoot, attack).
- For a virtual joystick, you can map `InputEventScreenDrag` events to calculate a 2D vector.

**Example (Custom Virtual Joystick Node):**
Attach this to a `Control` node with a knob sprite.

```gdscript
extends Control

var drag_radius = 50.0
var output_vector = Vector2.ZERO

func _input(event):
    if drag_radius <= 0.0:
        output_vector = Vector2.ZERO
        $Knob.position = Vector2.ZERO
        return

    if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.pressed):
        var local_pos = get_local_mouse_position()
        var clamped_pos = local_pos

        if local_pos.length() > drag_radius:
            clamped_pos = local_pos.normalized() * drag_radius

        output_vector = clamped_pos / drag_radius
        $Knob.position = clamped_pos
    elif event is InputEventScreenTouch and not event.pressed:
        output_vector = Vector2.ZERO
        $Knob.position = Vector2.ZERO
```

## Virtual Keyboards (Web & Mobile)

When a user focuses a `LineEdit` or `TextEdit`, the OS virtual keyboard appears. On mobile browsers, this can cover the bottom half of the game canvas.

### 1. Enable Experimental Virtual Keyboard (Web Only)

If exporting to the web, go to **Project > Export > Web (Html)** and check **Experimental Virtual Keyboard**.

### 2. Detecting Keyboard Height

To prevent the keyboard from covering your UI, you must detect its height and adjust your containers.

**Native Approach (Mobile/Desktop):**

```gdscript
var original_y = 0.0

func _ready():
    original_y = $FormVBoxContainer.position.y

func _process(_delta):
    var kb_height = DisplayServer.virtual_keyboard_get_height()
    if kb_height > 0:
        # Example: Push a VBoxContainer up so the focused input is visible
        $FormVBoxContainer.position.y = original_y - kb_height
    else:
        # Restore position when keyboard closes
        $FormVBoxContainer.position.y = original_y
```

**Web Approach (`JavaScriptBridge`):**
The native Godot function can be unreliable in web exports. Use the browser's `visualViewport` API:

```gdscript
var original_y = 0.0

func _ready():
    original_y = $FormVBoxContainer.position.y
    if OS.has_feature("web"):
        var vv = JavaScriptBridge.get_interface("visualViewport")
        if vv:
            var callback = JavaScriptBridge.create_callback(_on_browser_resize)
            vv.addEventListener("resize", callback)
        else:
            print("Visual Viewport API not supported.")

func _on_browser_resize(_args):
    var window = JavaScriptBridge.get_interface("window")
    var vv = JavaScriptBridge.get_interface("visualViewport")

    if not window or not vv:
        var fallback_height = DisplayServer.virtual_keyboard_get_height()
        if fallback_height > 0:
            $FormVBoxContainer.position.y = original_y - fallback_height
        else:
            $FormVBoxContainer.position.y = original_y
        return

    # Calculate the obscured height
    var kb_height = max(0.0, window.innerHeight - vv.height)

    # Push the form up if the keyboard is open
    if kb_height > 0:
        $FormVBoxContainer.position.y = original_y - kb_height
    else:
        $FormVBoxContainer.position.y = original_y
```
