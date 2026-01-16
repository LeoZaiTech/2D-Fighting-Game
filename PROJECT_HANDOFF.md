# 2D Fighting Game - Project Handoff Documentation

**Engine:** Godot 4.5 (GDScript)  
**Project Type:** 2D Sprite-Based Fighting Game  
**Current Phase:** Foundation Complete — Ready for Phase 2

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [File Structure](#file-structure)
3. [Core Systems Implemented](#core-systems-implemented)
4. [Scene Hierarchy](#scene-hierarchy)
5. [How Each System Works](#how-each-system-works)
6. [Current Controls](#current-controls)
7. [What Is NOT Implemented Yet](#what-is-not-implemented-yet)
8. [Recommended Next Steps](#recommended-next-steps)
9. [Code Reference](#code-reference)

---

## Project Overview

This is a **production-ready foundation** for a 2D fighting game. The architecture prioritizes:

- **Deterministic combat** (frame-based timing at 60 FPS)
- **State-driven characters** (finite state machine pattern)
- **Frame-accurate animation control** (hitboxes tied to animation frames)
- **Modularity** (easy to add new characters, states, and moves)

The project currently has:
- 1 playable character with Idle, Walk, Jump, and Light Attack states
- 1 training dummy that receives hits and enters hitstun
- A training stage with floor and debug UI
- Non-physics-based hitbox/hurtbox collision system
- 8-frame input buffer for responsive controls

---

## File Structure

```
project.godot                    # Godot config (input mappings, autoloads, window size)
icon.svg                         # Project icon
README.md                        # Quick reference documentation

assets/
└── sprites/
    ├── placeholder.svg          # Placeholder character sprite
    └── Custom_Edited-Mega...    # User's imported sprite sheet

scenes/
├── main/
│   ├── main.tscn                # Training stage (main scene)
│   └── main.gd                  # Debug display controller
└── characters/
    ├── player/
    │   └── player.tscn          # Player character scene
    └── dummy/
        └── dummy.tscn           # Training dummy scene

scripts/
├── autoload/                    # Singleton scripts (always loaded)
│   ├── game_manager.gd          # Global game state, combat events
│   └── input_buffer.gd          # Buffered input system
├── state_machine/               # Generic state machine system
│   ├── state_machine.gd         # FSM controller
│   └── base_state.gd            # Abstract state class
├── combat/                      # Combat collision system
│   ├── hitbox.gd                # Attack hitbox (Area2D)
│   └── hurtbox.gd               # Damage receiver (Area2D)
├── characters/
│   ├── base_character.gd        # Shared character logic
│   ├── character_animator.gd    # Programmatic animation setup
│   ├── player/
│   │   ├── player_character.gd  # Player-specific logic
│   │   └── states/
│   │       ├── idle_state.gd
│   │       ├── walk_state.gd
│   │       ├── jump_state.gd
│   │       ├── light_attack_state.gd
│   │       └── hitstun_state.gd
│   └── dummy/
│       ├── training_dummy.gd
│       └── states/
│           ├── dummy_idle_state.gd
│           └── dummy_hitstun_state.gd
└── util/
    └── animation_helper.gd      # Static animation utilities
```

---

## Core Systems Implemented

### 1. State Machine (`scripts/state_machine/`)

**Purpose:** Controls all character behavior through discrete states.

**Files:**
- `state_machine.gd` - The FSM controller that manages state transitions
- `base_state.gd` - Abstract base class all states extend

**Key Methods:**
```gdscript
# StateMachine
transition_to(state_name: String, params: Dictionary = {})  # Change state
is_in_state(state_name: String) -> bool                     # Check current state
get_state(state_name: String) -> BaseState                  # Get state reference

# BaseState (override these in child states)
enter(params: Dictionary)           # Called when entering state
exit()                              # Called when leaving state
physics_update(delta: float)        # Called every physics frame
frame_update(delta: float)          # Called every render frame
on_animation_finished(anim_name)    # Called when animation ends
can_be_interrupted() -> bool        # Whether state can be cancelled
```

**How to add a new state:**
1. Create a script extending `BaseState`
2. Override `enter()`, `physics_update()`, etc.
3. Add as child node of the character's `StateMachine` node
4. Call `state_machine.transition_to("new_state")` from other states

---

### 2. Input Buffer (`scripts/autoload/input_buffer.gd`)

**Purpose:** Stores recent button presses so inputs made slightly before an action becomes available still register.

**Buffer Window:** 8 frames (~133ms at 60 FPS)

**Key Methods:**
```gdscript
# Check if input was pressed recently (doesn't consume)
has_buffered_input(action: String) -> bool

# Check and consume the input (use for actions)
consume_input(action: String) -> bool

# Get current directional input (-1, 0, 1)
get_direction() -> int

# Check if crouch is held
is_holding_crouch() -> bool

# Clear all buffered inputs
clear_buffer()
```

**Registered Actions:**
- `move_left` (A key)
- `move_right` (D key)
- `jump` (W or Space)
- `crouch` (S key)
- `light_attack` (J key)

---

### 3. Hitbox/Hurtbox System (`scripts/combat/`)

**Purpose:** Non-physics-based attack collision. Hitboxes detect overlapping hurtboxes via Area2D signals.

**Design Principle:** Hitboxes are activated/deactivated by animation frames, NOT by physics.

**Hitbox Properties:**
```gdscript
@export var damage: int = 10
@export var hitstun_frames: int = 12
@export var knockback_force: Vector2 = Vector2(200, -50)
@export var hit_type: String = "mid"  # low, mid, high, overhead
```

**Key Methods:**
```gdscript
# Hitbox
activate()      # Enable collision detection
deactivate()    # Disable collision detection

# Hurtbox
receive_hit(hit_data: Dictionary)  # Called by hitbox on collision
set_active(active: bool)           # Enable/disable receiving hits
```

**Collision Layers:**
- Layer 4: Hitboxes
- Layer 5: Hurtboxes
- Hitboxes monitor Layer 5, Hurtboxes are on Layer 5

---

### 4. Base Character (`scripts/characters/base_character.gd`)

**Purpose:** Shared logic for all characters (player and dummy).

**Key Properties:**
```gdscript
@export var move_speed: float = 300.0
@export var jump_force: float = 500.0
@export var gravity: float = 1200.0

var facing_direction: int = 1       # 1 = right, -1 = left
var hitstun_remaining: int = 0      # Frames of stun left
var is_controllable: bool = true    # Can receive input
```

**Key Methods:**
```gdscript
set_facing(direction: int)              # Flip sprite based on direction
face_opponent(opponent_position: Vector2)
play_animation(anim_name: String)
is_in_hitstun() -> bool
get_state_name() -> String
```

---

### 5. Character Animator (`scripts/characters/character_animator.gd`)

**Purpose:** Programmatically creates placeholder animations. Replace with sprite-sheet-based animations.

**Currently Creates:**
- `idle` - Looping subtle bob
- `walk` - Looping bounce
- `jump` - Stretch effect
- `light_attack` - Lunge with hitbox activation at frames 5-10
- `hitstun` - Shake and flash red

---

### 6. Game Manager (`scripts/autoload/game_manager.gd`)

**Purpose:** Global singleton for game state and combat events.

**Key Properties:**
```gdscript
var current_state: GameState        # PLAYING, PAUSED, ROUND_START, ROUND_END
var frame_count: int = 0            # Deterministic frame counter
var player_character: Node
var training_dummy: Node
```

**Signals:**
```gdscript
signal combat_hit(attacker, defender, hit_data)
signal character_defeated(character)
```

---

## Scene Hierarchy

### Main Scene (`scenes/main/main.tscn`)
```
Main (Node2D)
├── Background (ColorRect)
├── Floor (StaticBody2D)
│   ├── FloorCollision (CollisionShape2D)
│   └── FloorVisual (ColorRect)
├── Player (player.tscn instance)
├── Dummy (dummy.tscn instance)
├── Camera2D
└── UI (CanvasLayer)
    └── DebugLabel (Label)
```

### Player Scene (`scenes/characters/player/player.tscn`)
```
Player (CharacterBody2D) [player_character.gd]
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine [state_machine.gd]
│   ├── Idle [idle_state.gd]
│   ├── Walk [walk_state.gd]
│   ├── Jump [jump_state.gd]
│   ├── Light_Attack [light_attack_state.gd]
│   └── Hitstun [hitstun_state.gd]
├── Hitbox (Area2D) [hitbox.gd]
│   └── HitboxShape (CollisionShape2D)
├── Hurtbox (Area2D) [hurtbox.gd]
│   └── HurtboxShape (CollisionShape2D)
└── CharacterAnimator [character_animator.gd]
```

### Dummy Scene (`scenes/characters/dummy/dummy.tscn`)
```
Dummy (CharacterBody2D) [training_dummy.gd]
├── Sprite2D (modulate: red tint)
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine [state_machine.gd]
│   ├── Idle [dummy_idle_state.gd]
│   └── Hitstun [dummy_hitstun_state.gd]
├── Hurtbox (Area2D) [hurtbox.gd]
│   └── HurtboxShape (CollisionShape2D)
└── CharacterAnimator [character_animator.gd]
```

---

## Current Controls

| Key | Action |
|-----|--------|
| A | Move Left |
| D | Move Right |
| W / Space | Jump |
| S | Crouch (input registered, no crouch state yet) |
| J | Light Attack |

---

## What Is NOT Implemented Yet

### Combat
- [ ] Blocking / guarding
- [ ] Crouch state and crouch attacks
- [ ] Medium and heavy attacks
- [ ] Special moves
- [ ] Combo system / cancel windows
- [ ] Juggle / launch mechanics
- [ ] Throw / grab system
- [ ] Super meter and super moves

### Visual/Audio
- [ ] Sprite-sheet-based frame animations
- [ ] Hit sparks / impact effects
- [ ] Sound effects
- [ ] Screen shake
- [ ] Hit freeze / hitstop

### Game Systems
- [ ] Health system and health bars
- [ ] Round system
- [ ] Win/lose conditions
- [ ] Character select
- [ ] Stage select
- [ ] Pause menu

### Training Mode
- [ ] Dummy behavior options (stand, jump, crouch, random)
- [ ] Input display
- [ ] Frame data display
- [ ] Hitbox visualization toggle
- [ ] Position reset

---

## Recommended Next Steps

### Phase 2: Combat Feel (Suggested Order)

1. **Set up sprite sheet animations**
   - Replace placeholder animations with actual sprite frames
   - Use AnimationPlayer with Sprite2D frame property
   - Sync hitbox activation to attack animation frames

2. **Add hitstop (hit freeze)**
   - Pause both characters for 3-5 frames on hit
   - Creates impactful feel

3. **Add hit sparks**
   - Spawn particle or animated sprite at hit position
   - Use `combat_hit` signal from GameManager

4. **Implement blocking**
   - New "Block" state
   - Reduced damage, no hitstun
   - Hold-back-to-block or dedicated button

5. **Add more attacks**
   - Medium Attack (K key?)
   - Heavy Attack (L key?)
   - Each with different startup/active/recovery frames
   - Different damage and hitstun values

6. **Implement crouching**
   - Crouch state
   - Crouch attacks
   - Low attacks that must be crouch-blocked

7. **Add combo system**
   - Cancel windows (allow next attack during recovery)
   - Chain combos (light → medium → heavy)
   - Link combos (timing-based)

---

## Code Reference

### Example: Adding a New Attack State

```gdscript
# scripts/characters/player/states/medium_attack_state.gd
class_name MediumAttackState
extends BaseState

var is_aerial: bool = false

@onready var hitbox: Hitbox = character.get_node_or_null("Hitbox")

func enter(params: Dictionary = {}) -> void:
    is_aerial = params.get("aerial", false)
    character.play_animation("medium_attack")
    character.velocity.x = 0
    
    # Configure hitbox for medium attack
    if hitbox:
        hitbox.damage = 20
        hitbox.hitstun_frames = 18
        hitbox.knockback_force = Vector2(300, -100)

func physics_update(_delta: float) -> void:
    if is_aerial and is_grounded():
        state_machine.transition_to("idle")

func on_animation_finished(anim_name: String) -> void:
    if anim_name == "medium_attack":
        state_machine.transition_to("idle")

func exit() -> void:
    if hitbox:
        hitbox.deactivate()

func can_be_interrupted() -> bool:
    return false
```

### Example: Creating Sprite-Based Animation

In AnimationPlayer, create a new animation with:
1. Add track: `Sprite2D:frame` (Value track)
2. Add keyframes for each animation frame
3. For attacks, add Method Call track:
   - Path: `Hitbox`
   - Key at startup frame: `activate()`
   - Key at recovery frame: `deactivate()`

### Example: Implementing Hitstop

```gdscript
# In game_manager.gd, add:
var hitstop_frames: int = 0

func apply_hitstop(frames: int) -> void:
    hitstop_frames = frames
    get_tree().paused = true

func _physics_process(delta: float) -> void:
    if hitstop_frames > 0:
        hitstop_frames -= 1
        if hitstop_frames <= 0:
            get_tree().paused = false
    # ... rest of logic

# Call from hitbox when hit lands:
GameManager.apply_hitstop(4)
```

---

## Frame Data Template

| Move | Startup | Active | Recovery | Total | Damage | Hitstun | On Block |
|------|---------|--------|----------|-------|--------|---------|----------|
| Light Attack | 5f | 6f | 7f | 18f | 10 | 12f | -2 |
| Medium Attack | 8f | 5f | 12f | 25f | 20 | 18f | -4 |
| Heavy Attack | 12f | 8f | 20f | 40f | 35 | 24f | -8 |

*At 60 FPS: 1 frame = 16.67ms*

---

## Architecture Principles

1. **State-driven behavior** — All character actions flow through the state machine
2. **Non-physics hitboxes** — Attack collisions are explicit, not emergent
3. **Frame-based timing** — Use frame counts, not delta time, for combat logic
4. **Modular systems** — Each system is independent and reusable
5. **Signals for communication** — Loose coupling between systems

---

## Questions for Further Development

When continuing development, consider:

1. What's your target combo complexity? (simple chains vs. links vs. cancels)
2. Do you want hold-back-to-block or a dedicated block button?
3. Will there be air blocking?
4. How many characters are planned?
5. Is this 1v1 only or will there be team modes?
6. What's the target platform? (affects input handling)

---

*Documentation generated for handoff to ChatGPT or other AI assistants.*
