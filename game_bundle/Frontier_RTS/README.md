# Overview

Original browser RTS prototype built with Godot 4.4.1 and GDScript using the Compatibility renderer. No Rust, React, Three.js, advertising or monetization. The project is intended to be free and open source; review `LICENSE` and asset licensing before publishing. No code or assets from the mechanically inspiring commercial game are used.

## Current RTS milestone

- Source delivery: `game_bundle/Frontier_RTS/` and `game_bundle/Frontier_RTS.zip` (not a browser build). Contains project files, assets, scenes, scripts, autoloads, export configuration, license and documentation; excludes caches, temporary files and Git history. Refresh the folder and ZIP after each subsequent project update before reporting completion; this is a delivery workflow, not an automatic background process. Open the extracted `Frontier_RTS/project.godot` in Godot 4.4.1. The parent `game_bundle/` is excluded from Git and Godot scanning via `.gdignore`.
- Design and complete target content catalog: `design/GAME_DESIGN_DOCUMENT.md`.
- Phase 1 code: deterministic flat 64 × 64 terrain map, MultiMesh tiles, grid, hovered/selected cell, and orthographic RTS camera.
- Main scene: `scenes/game.tscn`; camera scene: `scenes/rts_camera.tscn`.
- Scripts: `scripts/game.gd`, `scripts/rts/map_grid.gd`, `scripts/rts/rts_camera.gd`.
- Controls: screen edges or WASD/arrows to pan, mouse wheel to zoom, middle-button horizontal drag or Q/E to rotate, left click to select a cell. Clicking outside the map clears selection.
- Phase 2A: press 1 for stockpile (3 × 3, 30 wood), 2 for wheat farm (2 × 2, 20 wood), left click to build, Esc/right click to cancel. Placement mode stays active after building. Green preview means allowed; red means rejected.
- Stockpile requires sand/fertile ground; all farm cells require fertile ground. Bounds, occupied cells and costs are rechecked on click. Start with 200 wood, 100 stone, 100 iron, 100 food and 200 gold. No resource refunds or demolition yet.
- Construction: `scripts/rts/construction.gd`; definitions: `scripts/rts/building_definition.gd`, `assets/data/buildings/stockpile.tres`, `assets/data/buildings/wheat_farm.tres`.
- Phase 2B/2C/2F: population starts at 3 abstract workers. Production jobs are reassigned in construction order when buildings or population change (1 per current production building). Each staffed farm produces 2 wheat per 5 simulation seconds only when at least one stockpile exists.
- Farms without workers or a stockpile have zero progress. Building a stockpile starts a full cycle; additional stockpiles do not multiply output. Recipes and staffing are configured in `scripts/rts/building_definition.gd` and `assets/data/buildings/wheat_farm.tres`.
- Phase 2C: press 3 for mill and 4 for bakery. Each costs 30 wood, occupies 2 × 2 sand/fertile cells, requires a worker and a stockpile. Mill: 2 wheat → 2 flour in 4 seconds. Bakery: 1 flour → 2 bread in 4 seconds. Definitions: `assets/data/buildings/mill.tres`, `assets/data/buildings/bakery.tres`.
- Inputs are checked together and deducted once at cycle start. No inputs means no progress; output arrives only after the full cycle. Paid active cycles pause without losing inputs/progress if staffing/storage requirements are unmet. Competing buildings use construction order.
- Wheat, flour and bread start at 0. Build one farm, one mill and one bakery to use the 3-worker pool for a complete chain; extra farms can leave processors unstaffed.
- Phase 2D: press 5 for granary (30 wood, 3 × 3 sand/fertile cells, no workers). Definition: `assets/data/buildings/granary.tres`. Bakery now requires both stockpile and granary; an already paid cycle pauses without losing its inputs/progress if access is absent.
- Residents equal the current worker pool (initially 3), including idle workers. With a granary, every 10 simulation seconds each resident eats 1 unit: bread first, then the initial `food` reserve. Wheat/flour are not edible. Production runs before meals in each physics tick.
- No granary means no consumption and a reset meal timer; the first meal is a full 10 seconds after building one. Extra granaries do not multiply demand. Partial meals consume only available food and record the unfed count without negative balances. Hunger affects popularity and indirectly migration/staffing; storage capacity limits and food delivery are not implemented.
- Phase 2E: press 6 for treasury (20 stone, 2 × 2 sand/fertile cells, no workers), defined in `assets/data/buildings/treasury.tres`. T cycles taxes 0 → 1 → 2 → 0 gold/resident (default 0, no key repeat). Without a treasury there is no tax income or tax popularity penalty; multiple treasuries do not multiply either.
- Popularity starts at 50 and stays within 0–100. Every 10 seconds from simulation start: latest fully served meal +2; partial/missing meal −ceil(4 × unfed/residents); no granary −4; before the first meal with a granary, food modifier 0. Active treasury tax penalty is −2 × rate. Population 0 has no popularity change.
- Treasury collects residents × current rate every 10 seconds, first collection a full interval after treasury access. Changing rate does not reset the timer or pay immediately. Popularity is calculated after meals, then migration is applied.
- Phase 2F: after each 10-second society tick, popularity >=60 adds 1 resident up to `population_capacity` (default 10); popularity <40 removes 1 down to a minimum of 1. At 40–59 population is stable. A configured initial population of 0 stays empty as a diagnostic mode. Initial `worker_pool` is clamped to 0–capacity.
- Jobs are recomputed as complete crews in construction order. Later buildings lose workers first, and paid cycles pause/resume without consuming inputs again. Food and taxes in the current tick use pre-migration population; future ticks use the new count. The latest meal penalty uses population at meal time. Housing is not implemented: capacity is a temporary fixed parameter in `scripts/rts/construction.gd`.
- Phase 2G: press 7 for lumbermill (20 wood, 2 × 2 sand/fertile cells, 1 worker, stockpile required). Definition: `assets/data/buildings/lumbermill.tres`. Produces 4 wood per 5 seconds from the nearest tree with a full portion within 8 cells of the building center.
- Trees are deterministic green MultiMesh boxes on non-rock terrain, each with 24 wood; the central 8 × 8 area has no trees. All buildings are blocked by trees with remaining wood. No regrowth. A depleted tree is hidden and its cell is released when the final portion is reserved, before that portion finishes production.
- Tree wood is reserved once at cycle start and credited only after completion. Competing lumbermills reserve in construction order; missing workers/storage pause paid cycles without losing the portion. No nearby tree means no production. Placement preview does not guarantee a source is available. Gathering is abstract, with no physical woodcutters or transport.
- Phase 2H: press 8 for quarry (30 wood, 2 × 2 sand/fertile cells, 1 worker and stockpile). Definition: `assets/data/buildings/quarry.tres`. Reserves 4 stone from the nearest deposit within 8 cells of its center and delivers it to shared reserves after 6 seconds.
- Stone deposits are deterministic grey MultiMesh boxes on 25% of rock cells, 48 stone each, without regeneration. Deposits block building footprints. The quarry is built nearby, not over the deposit; placement preview does not guarantee a source. Depleted deposits disappear but rock terrain remains unchanged. Competition and paused paid cycles follow the existing gathering rules; workers and delivery are abstract.
- Phase 2I: press 9 for iron mine (30 wood + 10 stone, 2 × 2 sand/fertile cells, 1 worker and stockpile). Definition: `assets/data/buildings/iron_mine.tres`. Reserves 3 iron from the nearest deposit within 8 cells and credits it after 6 seconds. Starting iron remains 100.
- Iron deposits are rust-brown MultiMesh boxes with 36 iron each, deterministically placed on 15% of rock cells without stone deposits. No regeneration; depletion hides the deposit but leaves rock terrain unchanged. Deposits block construction. Build mines nearby, not over deposits. Reservation, competition and paused cycles follow existing gathering rules; no physical miners or deliveries.
- Phase 2J: press 0 for weaponsmith (30 wood + 10 stone, 2 × 2 sand/fertile cells, 1 worker and stockpile). Definition: `assets/data/buildings/weaponsmith.tres`. Consumes 2 iron once at cycle start and produces 1 sword after 8 seconds. `swords` starts at 0; existing worker assignment, input competition and paid-cycle pause/resume rules apply.
- Swords are stored in shared reserves for now, with no armory capacity, delivery, troop recruitment or equipment consumption. No new HUD; `[RTS Economy]` reports iron consumption, waiting states and sword output.
- Phase 2K: B selects the bow workshop (30 wood, 2 × 2 sand/fertile cells, 1 worker and stockpile). Definition: `assets/data/buildings/bow_workshop.tres`. Consumes 2 wood once at cycle start and produces 1 bow after 6 seconds; `bows` starts at 0. Existing staffing, input competition and paid-cycle pause/resume rules apply. Bows remain shared reserves, without armory capacity or recruitment.
- Eleven buildings are placeable primitive boxes. Workers are abstract assignments, not physical units. No worker travel, deliveries, manual reassignment, housing, storage capacity limits, navigation, combat, siege, saves or enemy AI yet. No new HUD or menus.
- Runtime acceptance still requires browser checks; editing-only validation is not a playtest.
- Key logs: `[RTS Map]`, `[RTS Camera]`, `[RTS Phase 2K]`, `[RTS Grid]`, `[RTS Build]`, `[RTS Economy]`, `[RTS Food]`, `[RTS Society]`, `[RTS Population]`, `[RTS Wood]`, `[RTS Stone]`, `[RTS Iron]`. Gathering logs report generation, reservation and depletion; economy logs report consumed inputs, output and waiting states.
- Browser acceptance for Phase 2B: farm alone produces nothing; add a stockpile and verify a full 5-second cycle; build four farms and verify only three operate; extra stockpiles must not change the rate. Build validation is not runtime verification.
- Browser acceptance for Phase 2C/2D: build stockpile + one farm + mill + bakery + granary; verify flour and bread arrive after full cycles, wheat/flour are charged only once per cycle, and processors without input or workers wait without free output. Competition checks require a larger test worker pool configured on `scripts/rts/construction.gd`.
- Food acceptance: verify no eating or bakery output without a granary, first meal after 10 seconds, bread-first mixed meals, insufficient/zero edible stocks, and unchanged meal rate with multiple granaries. Zero population requires a test worker pool of 0; runtime acceptance remains pending.
- Society acceptance: all tax rates, no treasury, multiple treasuries, first collection interval, full/partial/no meals, missing granary, popularity limits and zero population. These are pending browser checks, not completed playtests.
- Population acceptance: updated popularity thresholds 39/40/59/60, capacity, minimum 1, late-building job loss and resumption without double payment, changing meal/tax demand and stable meal penalty denominator. Prior fixed-3-worker acceptance checks describe earlier milestones; migration must now be considered. Browser checks remain pending.

The sections below document the original template structure where it remains applicable.
- Bow workshop acceptance (pending browser checks): B, placement/price, one debit of 2 wood per 6-second cycle, no input/worker/stockpile, competition for the final portion and pause/resume without a second debit. Source folder refreshed for Phase 2K; ZIP creation remains unconfirmed after shell timeouts.
- Weaponsmith acceptance (pending browser checks): key 0, footprint and price, one debit of 2 iron per full 8-second cycle, no input/worker/stockpile, competing workshops with only 2 iron left, pause/resume without a second debit. Staffing may require population growth or a different construction order.
- Iron acceptance (pending browser checks): separate stone/iron deposits, deterministic generation, blocked footprints, radius/map edges, final-portion competition, full 6-second output, no worker/stockpile/source, pause/resume without double reservation, depletion without terrain changes. A mine may wait for population growth if earlier buildings occupy all workers.
- Stone acceptance (pending browser checks): deterministic deposits, blocked footprints, radius/map edges, competition for the final portion, full 6-second output, no worker/stockpile/source, pause/resume without double reservation, and depletion without changing rock terrain. Staffing may require population growth or a different construction order.
- Wood acceptance (pending browser checks): repeatable trees, tree-blocked footprints, full-cycle output, no worker/stockpile/source, overlapping gathering areas without duplicate portions, radius/map edges, depletion and released cells. The food chain uses the initial three workers; lumbermill staffing may require population growth or a different building order.

## Table of Contents

- [Introduction](#introduction)
- [Folder Structure](#folder-structure)
- [Getting Started](#getting-started)
- [Godot Engine Overview](#godot-engine-overview)
- [File Explanations](#file-explanations)
- [Customization Guide](#customization-guide)
- [Notes for AI Assistants](#notes-for-ai-assistants)

## Introduction

Godot is an open-source, cross-platform game engine used for creating both 2D and 3D games. It's known for its user-friendly workflow and powerful scripting capabilities (GDScript).

This template leverages Godot 4.4.1 to provide a streamlined, organized structure to kickstart your game projects effectively.

## Folder Structure

The project is organized as follows:

- `addons/`: Godot plugins and Asset Library add-ons. Enable plugins in Jabali Studio project settings. (This folder may appear once a plugin is added.)
- `autoload/`: Singleton scripts that persist across scenes and provide global functionality.
- `scenes/`: Scene files (`.tscn`) that define game elements, UI, and levels.
- `scripts/`: GDScript files (`.gd`) used to define logic and behaviors.
- `assets/`: Game assets organized by type:
  - `textures/`: Images, sprites, UI elements.
  - `audio/`: Sound effects and music.
  - `fonts/`: Custom fonts for game UI.
- `project.godot`: Main configuration file storing project settings and metadata.
- `*.uid`: Godot 4 UID sidecar files for scripts/resources. Keep them alongside their paired files.

## Getting Started

### 1. Open the Project

- Open this folder in Jabali Studio.
- The main scene is `scenes/game.tscn` (as configured in `project.godot`).
- `scenes/start.tscn` is retained unused template scaffolding; startup enters the RTS map directly.

### 2. Create or Modify Scenes

- Create new scenes (`.tscn`) in the `scenes/` folder.
- Attach scripts from the `scripts/` folder to nodes.

### 3. Add Assets

Either ask the copilot to generate assets or upload them manually:

- Place images into `assets/textures/`.
- Place audio files into `assets/audio/`.
- Fonts go into `assets/fonts/`.

Godot automatically manages import settings upon detecting new assets.

## Godot Engine Overview

Godot Engine 4.4.1 provides robust and accessible tools for creating engaging 2D and 3D experiences. Key features include:

- **Rendering Engine:** Supports advanced 2D and 3D rendering with Vulkan/OpenGL backends.
- **Scene and Node System:** Uses a flexible, hierarchical node-based system for game objects.
- **Built-in Physics:** Provides comprehensive 2D and 3D physics engines.
- **GDScript:** A Python-like scripting language designed specifically for Godot.
- **Cross-Platform Deployment:** Export your game to Windows, macOS, Linux, Android, iOS, and Web.
- **Plugin System:** Extend the runtime with add-ons in `addons/`.

## File Explanations

### `project.godot`

- **Purpose:** Main configuration file containing all global project settings.
- **Key Configurations:**
  - Display/window settings
  - Physics parameters
  - Input mappings
  - Autoload singleton management

### `export_presets.cfg` and `export_page.html`

- **Purpose:** Export presets for builds. The Web preset uses `export_page.html` as a custom HTML shell.
- **Notes:** Only adjust these if you are changing export targets or web presentation.

### `publish.yml` and `.editorignore`

- **Purpose:** Build metadata for automation tooling.
- **Notes:** `publish.yml` is ignored by Godot because it is listed in `.editorignore`.

### Scenes (`scenes/*.tscn`)

- **Purpose:** Scene files define layouts, objects, and hierarchies for gameplay, UI, and levels.
- **Usage:** Attach scripts to define scene-specific behaviors.

### Scripts (`scripts/*.gd` and `*.uid`)

- **Purpose:** Implements game logic, event handling, character behaviors, and interactions.
- **Structure:**
  - Each script typically extends a Godot node type (e.g., `Node`, `Node2D`, `Node3D`, `Control`).
  - Common lifecycle functions include `_ready()`, `_process(delta)`, and `_physics_process(delta)`.
- **Notes:** `*.uid` files are auto-generated sidecars. Keep them with their scripts.

## Customization Guide

### Adding New Scenes

- Create scenes within the `scenes/` folder.
- Attach scripts from the `scripts/` directory.

### Adding Singleton (Autoload) Scripts

- Place global scripts into the `autoload/` folder.
- Register them in Jabali Studio project settings (which updates `project.godot`).

### Installing Plugins (Add-ons)

- Install plugins from the Asset Library or by copying them into `addons/`.
- Enable them in Jabali Studio project settings.

### Asset Management

- Organize your assets clearly within their respective subdirectories in `assets/`.
- Godot automatically recognizes and imports supported assets; customize import settings in Jabali Studio as needed.

### Exporting

- Update `export_presets.cfg` for new targets.
- If exporting for Web, edit `export_page.html` for branding and loading UI.

## Notes for AI Assistants

- **Respect Project Settings:** The main scene is `scenes/game.tscn`. The template `GameManager` autoload remains registered but does not own RTS state.
- **Use Godot Paths:** Reference assets with `res://` paths and keep them aligned with the folder structure.
- **Keep Sidecar Files:** Do not delete or rename `*.uid` files without updating the paired resource.
- **Prefer Jabali Studio Changes:** When possible, adjust scenes and project settings via Jabali Studio to avoid config drift.
- **Plugins:** If a feature relies on an add-on, ensure it exists under `addons/` and is enabled in Jabali Studio project settings.
- **Web Exports:** The Web preset relies on `export_presets.cfg` and `export_page.html`.

Happy coding and game developing!
