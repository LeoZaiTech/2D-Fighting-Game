# 2D Fighting Game Foundation

A production-ready foundation for a 2D sprite-based fighting game built in **Godot 4.x**.

## Controls

| Action | Key |
|--------|-----|
| Move Left | A |
| Move Right | D |
| Jump | W / Space |
| Crouch | S |
| Light Attack | J |

## Project Structure

```
├── project.godot              # Godot project config with input mappings
├── scenes/
│   ├── main/
│   │   ├── main.tscn          # Training stage scene
│   │   └── main.gd            # Debug display controller
│   └── characters/
│       ├── player/
│       │   └── player.tscn    # Playable character scene
│       └── dummy/
│           └── dummy.tscn     # Training dummy scene
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd    # Global game state & combat events
│   │   └── input_buffer.gd    # Buffered input system (8-frame window)
│   ├── state_machine/
│   │   ├── state_machine.gd   # Generic FSM for characters
│   │   └── base_state.gd      # Abstract state class
│   ├── combat/
│   │   ├── hitbox.gd          # Attack collision (non-physics)
│   │   └── hurtbox.gd         # Damage receiver
│   ├── characters/
│   │   ├── base_character.gd  # Shared character logic
│   │   ├── character_animator.gd # Programmatic animation setup
│   │   ├── player/
│   │   │   ├── player_character.gd
│   │   │   └── states/
│   │   │       ├── idle_state.gd
│   │   │       ├── walk_state.gd
│   │   │       ├── jump_state.gd
│   │   │       ├── light_attack_state.gd
│   │   │       └── hitstun_state.gd
│   │   └── dummy/
│   │       ├── training_dummy.gd
│   │       └── states/
│   │           ├── dummy_idle_state.gd
│   │           └── dummy_hitstun_state.gd
│   └── util/
│       └── animation_helper.gd # Static animation utilities
└── assets/                     # Place sprites here
    └── sprites/
```

## Core Systems

### State Machine
Characters are driven by a finite state machine (`StateMachine` + `BaseState`).

**To add a new state:**
1. Create a new script extending `BaseState`
2. Override `enter()`, `exit()`, `physics_update()`, and `on_animation_finished()`
3. Add the state as a child node of the character's `StateMachine` node
4. Transition using `state_machine.transition_to("state_name")`

```gdscript
# Example: New "Dash" state
class_name DashState
extends BaseState

func enter(_params: Dictionary = {}) -> void:
    character.play_animation("dash")
    character.velocity.x = character.facing_direction * 600

func physics_update(_delta: float) -> void:
    # Return to idle when animation finishes
    pass

func on_animation_finished(anim_name: String) -> void:
    if anim_name == "dash":
        state_machine.transition_to("idle")
```

### Input Buffer
Inputs are buffered for 8 frames (configurable in `input_buffer.gd`).

```gdscript
# Check for buffered input
if InputBuffer.has_buffered_input("light_attack"):
    InputBuffer.consume_input("light_attack")
    # Perform attack

# Get current direction (-1, 0, 1)
var dir = InputBuffer.get_direction()
```

### Hitbox / Hurtbox System
**Non-physics based** - hitboxes detect overlaps with hurtboxes via Area2D signals.

- **Hitbox**: Attached to attacker, activated/deactivated via animation frames
- **Hurtbox**: Attached to defender, receives hit data and emits `hit_received` signal

**To add a new attack:**
1. Create the animation in AnimationPlayer
2. Add method call keys to activate/deactivate the hitbox at specific frames
3. Configure hitbox properties (damage, hitstun, knockback)

```gdscript
# Hitbox activation via animation (at frame 5, ~0.083s at 60fps)
# In AnimationPlayer, add a Method Call track:
# - Path: Hitbox
# - Method: activate() at start of active frames
# - Method: deactivate() at end of active frames
```

### Adding Sprites
1. Place your sprite sheet in `assets/sprites/`
2. In the character scene, select `Sprite2D`
3. Set the texture to your sprite sheet
4. Configure `Hframes` and `Vframes` for sprite sheet layout
5. Update `CharacterAnimator` or create frame-based animations in AnimationPlayer

## Frame Data Reference

| Move | Startup | Active | Recovery | Total |
|------|---------|--------|----------|-------|
| Light Attack | 5f | 6f | 7f | 18f |

*Frame timings at 60 FPS (1 frame = 16.67ms)*

## Architecture Notes

- **Deterministic**: Frame-based timing for consistent behavior
- **State-driven**: All character behavior flows through the state machine
- **Modular**: Systems are decoupled and reusable
- **Extensible**: Add new characters by duplicating and modifying existing scenes

## Next Steps (Phase 2)

- [ ] Add more attack types (Medium, Heavy, Special)
- [ ] Implement blocking system
- [ ] Add combo system with cancel windows
- [ ] Create character-specific move sets
- [ ] Add visual/audio feedback (hit sparks, sounds)
