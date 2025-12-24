# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mole Heist is a multiplayer heist game built in Godot 4.4 where two players compete to steal treasure while avoiding guards across 3 rounds. One player controls a Mole (can dig underground), the other controls a Raccoon (can dash).

## Development Commands

### Running the Game
- **Open in Godot Editor**: Open the project folder in Godot 4.4+
- **Run Game**: Press F5 in Godot Editor or click the "Play" button
- **Run Specific Scene**: Press F6 to run the currently open scene

### Testing Multiplayer Locally
1. Run the game once (this will be the host)
2. Click "Start Game" → "Host"
3. Run a second instance from command line: `godot --path /path/to/project`
4. On the second instance: "Start Game" → "Join" → enter `127.0.0.1`

### Running Integration Tests
```bash
# Run all integration tests
./tests/run_tests.sh

# Run individual test
godot --headless --path . tests/integration/test_round_timer_sync.gd
```

**Test Coverage:** 6 integration test suites covering:
- Round timer synchronization
- Loot pickup (simultaneous pickups, double-pickup prevention)
- Key collection (increment validation, server authority)
- Door opening (animation sync, key consumption)
- Connection failure handling
- Round wins and tie scenarios

See `tests/README.md` for detailed test documentation.

### Building the Game

```bash
# Build for specific platform
./build.sh macos
./build.sh windows
./build.sh linux

# Build for all platforms
./build.sh all
```

**Prerequisites:**
- Godot 4.4+ export templates (install via Editor → Manage Export Templates)

See `BUILD.md` for detailed build documentation.

### Project Structure
```
Scripts/
  ├── gm.gd           # Game Manager (autoload singleton)
  ├── sm.gd           # Server Manager (autoload singleton)
  ├── math.gd         # Math utilities (autoload singleton)
  └── Player/
      ├── player.gd   # Base player class
      ├── mole.gd     # Mole character (dig ability)
      └── raccoon.gd  # Raccoon character (dash ability)
Levels/
  ├── main.tscn       # Main gameplay scene
  ├── hostjoin.tscn   # Multiplayer lobby
  └── [other scenes]
```

## Architecture

### Game Flow
```
menu.tscn
  → hostjoin.tscn (multiplayer setup)
  → character_select.tscn
  → main.tscn (3 rounds of gameplay)
  → postround.tscn (after each round)
  → hostwin.tscn / joinerwin.tscn / tie.tscn (final results)
```

### Autoload Singletons

Access these globally from any script:

- **GM** (`Scripts/gm.gd`): Core game state manager
  - Round management (3 rounds, 60 seconds each)
  - Player scores (`p1_round_value`, `p2_round_value`, `p1_total_value`, `p2_total_value`)
  - Win tracking (`p1_wins`, `p2_wins`)
  - Key inventory (`p1_keys`, `p2_keys`)
  - Game lifecycle RPCs: `start_game()`, `new_round()`, `end_round()`, `end_game()`

- **SM** (`Scripts/sm.gd`): Multiplayer/network manager
  - Handles ENet server/client setup
  - Port: 1234 (hardcoded)
  - Methods: `host_game(port)`, `join_game(ip, port)`, `send_player_info.rpc()`
  - Max 2 players (peer-to-peer)

- **Math** (`Scripts/math.gd`): Vector math utilities

- **hud** (`hud.tscn`): HUD overlay scene (punishment labels)

### Multiplayer Architecture

**Authority Model:**
- **Server-Authoritative**: Spawning (players, loot, keys), pickup validation, game state transitions
- **Client-Authoritative**: Player movement, camera, ability usage

**Player IDs:**
- Host: `GM.p1_id = 1` (always peer ID 1)
- Client: `GM.p2_id` (assigned on connection, typically 2)
- Set via `set_multiplayer_authority(id)` on player nodes

**RPC Patterns Used:**
```gdscript
# State sync across all peers
@rpc("call_local")
func start_game()

# Server-to-client authoritative updates
@rpc("authority", "call_local", "reliable")
func _sync_loot(index, value, seed)

# Client request → Server validation
@rpc("any_peer")
func request_pickup_completion(picker_id)
```

### Entity Groups

Defined in `project.godot` [global_group]:
- `"player"` - Both player characters (used by guards for detection)
- `"loot"` - Treasure items (interaction target)
- `"door"` - Doors requiring keys
- `"key"` - Key pickups

Access via `is_in_group("group_name")`

### Spawning System

**MultiplayerSpawner Pattern:**
- Server spawns all entities (players, loot, keys)
- Uses Godot's `MultiplayerSpawner` node with spawn_function
- Players spawn at fixed positions (SPAWN_1, SPAWN_2 in `main.gd`)
- Loot/keys spawn at random Marker3D positions (6 loot, 4 keys per round)

**Spawner Files:**
- `Levels/main.gd`: Player spawning
- `Levels/loot_spawner.gd`: Treasure spawning (random value 10-50, random mesh)
- `Levels/key_spawner.gd`: Key spawning

### Player Mechanics

**Base Class:** `Scripts/Player/player.gd` (CharacterBody3D)
- WASD movement with 3D camera on pivot (mouse look)
- Interaction system: Hold E for loot (2s progress bar), Press E for keys/doors
- Punishment system: 10-second timeout when caught by guards (teleport to spawn)
- Authority check: `if is_multiplayer_authority()` before processing input

**Character Abilities (Q key):**
- **Mole** (`Scripts/Player/mole.gd`): Dig underground for 10 seconds (invisible to guards)
- **Raccoon** (`Scripts/Player/raccoon.gd`): Instant forward dash

**Interaction Detection:**
- Area3D node detects interactables via `body_entered`/`exited`
- Manages `interactable` reference (currently overlapping entity)
- Method `_manage_interactable()` handles E key press logic

### Loot System

**Pickup Flow:**
1. Client holds E → `start_pickup(player_id)`
2. RPC broadcasts `update_pickup_state.rpc(true, player_id)` to all clients
3. Local progress bar fills over 2 seconds
4. On completion:
   - If server: directly updates `GM.p1/p2_round_value`, adds to inventory
   - If client: `rpc_id(1, "request_pickup_completion")` → server validates
5. Server broadcasts `hide_item.rpc()` and `queue_free()`

**Synchronization:**
- Server generates random mesh/value on spawn
- `_sync_loot.rpc(index, value, random_seed)` ensures deterministic rendering on all clients
- Uses shared random seed for consistency

### Guard System

**Detection:** `Scripts/guard.gd`
- Vision cone (Area3D) detects players in `"player"` group
- Patrol via PathFollow3D on Path3D nodes
- On detection: `target.punishment()` → teleport + 10s timeout

**Note:** Listening/sound detection is commented out but implemented

### Door & Key System

**Doors:** `door.gd`
- Require 1 key to unlock (consumes from `GM.p1_keys` or `GM.p2_keys`)
- AnimationTree with "unlock" condition
- RPC syncs opening animation across clients

**Keys:** `key.gd`
- Instant pickup (no progress bar)
- 4 keys spawn per round at random positions
- Updates key counter UI automatically

### Round Lifecycle

1. `GM.new_round.rpc()` resets scores and timers
2. `main.gd._ready()` spawns players, loot, and keys (server only)
3. `GM._process()` counts down `round_dur` (60 seconds)
4. When `round_dur <= 0` → `GM.end_round()`
5. Compares `p1_round_value` vs `p2_round_value`, awards win
6. If `round < 3`: transition to `postround.tscn`
7. If `round == 3`: `end_game()` → compare total wins → show result screen

### UI Pattern

Labels auto-update from GM state in `_process()`:
```gdscript
# Example: timer.gd, host_val.gd, etc.
func _process(delta):
    text = str(GM.round_dur)
```

Files using this pattern: `timer.gd`, `round_counter.gd`, `host_val.gd`, `join_val.gd`, `host_wins.gd`, `join_wins.gd`

### Inventory System

**Inventory:** `inventory.gd`
- 2-slot grid container
- Tracks total value (sum of items)
- Method: `add_item(item: Item)` where Item is a Resource class

**ItemSlot:** `item_slot.gd`
- Visual representation with icon and value label
- Dictionary-based storage

**Item Resource:** `Scripts/item.gd`
```gdscript
class_name Item extends Resource
@export var name: String
@export var inv_icon: Texture2D
@export var value: int
```

## Important Conventions

### Godot-Specific
- **Scene instantiation**: Use `@export var scene: PackedScene` + `scene.instantiate()`
- **Animation**: AnimationTree with conditions: `$AnimationTree.set("parameters/conditions/walk", true)`
- **Tweens**: Camera/transform animations via `create_tween()`
- **Timers**: One-shot timers for temporary effects (dig duration, punishment timeout)

### Multiplayer Best Practices
- Always check `is_multiplayer_authority()` before processing input
- Use `@rpc("call_local")` for state that all peers need
- Server (peer ID 1) validates all pickups/interactions
- Set authority explicitly: `set_multiplayer_authority(player_id)`

### File Organization
- Player scripts in `Scripts/Player/`
- Level scenes in `Levels/`
- Autoload scripts in `Scripts/` root
- Spawner scripts alongside level scenes

### Input Bindings
Defined in `project.godot`:
- WASD: Movement (up/left/down/right)
- Q: Character ability (skill)
- E: Interact
- ESC: Pause/menu (escape)
- 0-3: Debug sound radius adjustment

## Common Gotchas

- **Round duration**: Defined as `ROUND_DURATION = 60` in `gm.gd`, not in level scenes
- **Spawn positions**: Hardcoded in `main.gd` as `Vector3(-1, 0, 6)` and `Vector3(1, 0, 6)`
- **Port**: Hardcoded to 1234 in `hostjoin.tscn` and `sm.gd`
- **Player count**: Fixed at 2 players, not scalable without architecture changes
- **Scene reloading**: Each round fully reloads `main.tscn` (not reset-based)
- **Authority**: Loot/key spawning only happens on server; clients rely on RPCs
- **Interaction progress**: Loot requires 2-second hold; keys/doors are instant
