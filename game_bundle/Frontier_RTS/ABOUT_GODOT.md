# About Godot

Godot is an open-source, cross-platform game engine designed to create versatile, interactive 2D and 3D games. With its intuitive node-based architecture and powerful scripting language (GDScript), Godot offers an efficient development experience. This document provides an overview of Godot 4.4.1 and explains how to use it with this game template.

## What is Godot?

Godot simplifies game development by offering comprehensive, built-in tools and a user-friendly workflow. Its primary features include:

- **Scene and Node Architecture:** Projects are organized into scenes composed of nodes, allowing for modular and reusable game elements.
- **GDScript Scripting Language:** An easy-to-learn, Python-like scripting language optimized for fast iteration and robust game logic.
- **Scene Tooling:** Built-in scene tools support direct manipulation of game objects, scenes, and UI elements.
- **Built-in Physics Engines:** Built-in support for 2D and 3D physics for handling collisions, gravity, forces, and dynamic interactions.
- **Asset Management:** Automatically manages asset imports, supporting textures, audio files, fonts, animations, and more.
- **Animation System:** Built-in tools for creating and managing animations for both characters and UI elements.
- **Cross-Platform Deployment:** Export projects to Windows, macOS, Linux, Android, iOS, and Web.
- **Add-ons and Plugins:** Extend the runtime and tooling with Asset Library add-ons stored under `addons/`.
- **Extensibility:** Supports custom modules and GDExtension for advanced integrations.

## Core Concepts

- **Scenes and Nodes:** Scenes are reusable collections of nodes; nodes provide behavior and structure.
- **Resources:** Assets, scripts, and scenes are referenced via resource paths such as `res://`.
- **Project and User Paths:** Use `res://` for project files and `user://` for per-user data like saves.

## Godot in This Template

This template for Godot 4.4.1 is structured for quick setup and scalability across both 2D and 3D projects:

- **`project.godot`:** Main configuration file for project settings, autoloads, and the main scene.
- **`scenes/`:** Scene files (`.tscn`) for gameplay, UI screens, characters, and levels.
- **`scripts/`:** GDScript files (`.gd`) for gameplay logic and interactions.
- **`autoload/`:** Global singleton scripts (autoloads) available to every scene.
- **`assets/`:** Organized asset storage for textures, audio, and fonts.
- **`addons/`:** Plugins and add-ons from the Asset Library (enable via Jabali Studio project settings).
- **`export_presets.cfg`:** Export configurations (includes Web export).
- **`export_page.html`:** Custom HTML shell for Web exports.
- **`publish.yml`:** Build metadata for automation tooling (ignored by Godot via `.editorignore`).
- **`*.uid`:** Godot-generated UID sidecar files for scripts/resources.
- **Starter intent:** Included scenes/scripts are intentionally minimal and can be replaced with either a 2D or 3D scene tree.

## Detailed Starter Examples (2D + 3D)

### Scene Examples

These are typical scene files you will create or expand for either 2D or 3D games:

- `scenes/start.tscn`: Main menu or title screen (already included).
- `scenes/game.tscn`: Gameplay root (already included).
- `scenes/player.tscn`: Reusable player character scene (2D or 3D).
- `scenes/enemy_basic.tscn`: Example enemy scene.
- `scenes/level_01.tscn`: A level layout scene that instantiates gameplay actors.

Example node layout for a menu scene:

```text
scenes/start.tscn
StartScreen (Control)
- CenterContainer
- VBoxContainer
- Label (Title)
- Button (Play)
```

Example node layout for a 2D gameplay scene:

```text
scenes/game.tscn
Game (Node2D)
- TileMap
- Player (CharacterBody2D)
- Enemies (Node2D)
- Camera2D
- UI (CanvasLayer)
- AudioStreamPlayer
```

Example node layout for a 3D gameplay scene:

```text
scenes/game.tscn
Game (Node3D)
- WorldEnvironment
- Player (CharacterBody3D)
- Enemies (Node3D)
- Camera3D
- DirectionalLight3D
- UI (CanvasLayer)
```

### Resource File Examples

Common starter resource files and how they are used:

- `res://assets/textures/player.png`: Assigned to `Sprite2D.texture`.
- `res://assets/textures/tileset.png`: Source image for a `TileSet`.
- `res://assets/textures/player_frames.tres`: `SpriteFrames` resource for `AnimatedSprite2D`.
- `res://assets/audio/sfx_jump.ogg`: Jump sound for `AudioStreamPlayer`.
- `res://assets/audio/music_level_01.ogg`: Music loop for `AudioStreamPlayer`.
- `res://assets/fonts/ui_font.ttf`: UI font used by a `Theme` resource.
- `res://assets/models/player.glb`: 3D player model used by `MeshInstance3D` or imported scene instances.
- `res://assets/materials/player.tres`: 3D material resource.
- `res://assets/ui_theme.tres`: Shared UI theme resource for menus and HUD.
- `res://scenes/player.tscn`: A `PackedScene` resource for instancing the player.

### Script Examples

Menu button that moves from the start scene to the gameplay scene:

```gdscript
# scripts/start.gd
extends Control

func _on_play_button_pressed():
    get_tree().change_scene_to_file("res://scenes/game.tscn")
```

Basic 2D player movement with jumping:

```gdscript
# scripts/player.gd
extends CharacterBody2D

@export var speed := 220.0
@export var jump_velocity := -420.0
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y += gravity * delta

    var input_dir := Input.get_axis("move_left", "move_right")
    velocity.x = input_dir * speed

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    move_and_slide()
```

Basic 3D player movement with jumping:

```gdscript
# scripts/player_3d.gd
extends CharacterBody3D

@export var speed := 5.5
@export var jump_velocity := 4.5
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    move_and_slide()
```

Pickup item that increments score and disappears:

```gdscript
# scripts/pickup_coin.gd
extends Area2D

@export var value := 1

func _on_body_entered(body):
    if body.is_in_group("player"):
        GameManager.add_score(value)
        queue_free()
```

HUD label that reflects the current score:

```gdscript
# scripts/ui.gd
extends CanvasLayer

@onready var score_label = %ScoreLabel

func _process(_delta):
    score_label.text = str(GameManager.get_score())
```

### Common Tasks

Instantiate enemies or pickups at runtime:

```gdscript
@export var enemy_scene: PackedScene

func spawn_enemy(spawn_position: Vector2):
    var enemy = enemy_scene.instantiate()
    enemy.global_position = spawn_position
    add_child(enemy)
```

Trigger damage when a hurtbox overlaps the player:

```gdscript
# scripts/hurtbox.gd
extends Area2D

@export var damage := 1

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.take_damage(damage)
```

Persist simple save data to disk:

```gdscript
func save_game():
    var data = {
        "score": GameManager.get_score(),
        "scene": get_tree().current_scene.scene_file_path
    }
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
```

## Common Pitfalls

These are frequent issues that slow down Godot development and how to avoid them:

- **Missing input actions:** If `Input.is_action_pressed("move_right")` returns false, add the action to input mappings (stored in `project.godot`).
- **Wrong scene paths:** Use `res://` paths, and keep them in sync with your folder structure.
- **Forgetting to connect signals:** UI buttons and `Area2D` triggers require signal connections or they will never fire.
- **Node path breakage:** Renaming nodes changes `$Path/To/Node` and `%NamedNode` references. Update scripts after renames.
- **Mixing `_process` and physics:** Use `_physics_process` for movement and collisions. Use `_process` for visuals and UI updates.
- **No collision shapes:** 2D bodies need `CollisionShape2D`, while 3D bodies need `CollisionShape3D`.
- **Global vs local coordinates:** Use `global_position` when placing things in world space, and `position` for local offsets.
- **Scene-only state:** If you need state across scenes, move it into an autoload (e.g., `GameManager`).
- **Save path confusion:** Write saves to `user://` instead of `res://` to avoid permission and packaging issues.
- **Deleted `.uid` files:** Keep `*.uid` files paired with their scripts and resources to avoid broken references.

## Add-ons and Plugins

Godot supports runtime and tooling extensions via add-ons:

- Add-ons live in `addons/` and usually come from the Asset Library or a plugin repository.
- Enable or disable them in Jabali Studio project settings.
- Keep plugin files self-contained under `addons/` to avoid path confusion.

## Advanced Godot Concepts

### Scene Management

Godot simplifies scene transitions with built-in methods:

#### Changing scenes

```gdscript
get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

#### Instantiating scenes at runtime

```gdscript
var enemy_scene = load("res://scenes/enemy.tscn")
var enemy = enemy_scene.instantiate()
add_child(enemy)
```

### Physics Integration

Utilize built-in physics nodes (e.g., `CharacterBody2D`/`CharacterBody3D`, `RigidBody2D`/`RigidBody3D`, `Area2D`/`Area3D`) for collisions and interactions:

```gdscript
func _physics_process(delta):
    velocity.y += gravity * delta
    move_and_slide()
```

### Input Handling

Godot offers robust input handling:

```gdscript
func _process(delta):
    if Input.is_action_pressed("move_right"):
        position.x += 200 * delta
```

Configure inputs in `project.godot`.

### Tweens and Animation

Godot provides efficient tools for smooth animations using built-in tweens:

```gdscript
var tween = create_tween()
tween.tween_property($AnimatedNode, "position:x", 500, 1.0).set_trans(Tween.TRANS_SINE)
tween.set_ease(Tween.EASE_IN_OUT)
```

## Conclusion

This overview provides a robust starting point for developing interactive games using Godot 4.4.1 with the provided template. The clear separation of concerns between scripts, scenes, assets, and add-ons ensures quick setup, organized development, and easy scalability.

For more comprehensive documentation, tutorials, and community resources, visit the official Godot Documentation.

Happy coding and game developing!
