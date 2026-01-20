# Animation System Synopsis - Walk/Run Animation Setup

**Engine:** Godot 4.5 (GDScript)  
**Goal:** Create a proper walk/run animation using sprite sheet frames

---

## Current Setup

### Sprite Sheet Configuration
- **File:** `assets/sprites/Megan Sprite Sheet Updated.png`
- **Current region:** `Rect2(323.31232, 26.518478, 39.82489, 42.36689)` (single idle frame)
- **Scale:** 4x
- **Shader:** White background removal shader applied

### Player Scene Node Structure
```
Player (CharacterBody2D)
├── Sprite2D              ← Displays the sprite, uses region_rect for frame selection
├── AnimationPlayer       ← Controls animations (currently has placeholder anims)
├── StateMachine
│   ├── Idle              ← Calls character.play_animation("idle")
│   ├── Walk              ← Calls character.play_animation("walk")
│   ├── Jump
│   ├── Light_Attack
│   └── Hitstun
├── Hitbox
├── Hurtbox
└── CharacterAnimator     ← Creates placeholder animations programmatically
```

---

## Key Files for Animation

### 1. Walk State (`scripts/characters/player/states/walk_state.gd`)
```gdscript
func enter(_params: Dictionary = {}) -> void:
    character.play_animation("walk")  # ← Triggers "walk" animation

func physics_update(_delta: float) -> void:
    var direction = player.get_input_direction()
    if direction == 0:
        state_machine.transition_to("idle")
        return
    player.velocity.x = direction * player.move_speed
    player.set_facing(direction)  # ← Flips sprite via flip_h
```

### 2. Base Character (`scripts/characters/base_character.gd`)
```gdscript
func play_animation(anim_name: String) -> void:
    if animation_player and animation_player.has_animation(anim_name):
        animation_player.play(anim_name)

func set_facing(direction: int) -> void:
    facing_direction = sign(direction)
    if sprite:
        sprite.flip_h = facing_direction < 0  # ← Flips sprite for left/right
```

### 3. Character Animator (`scripts/characters/character_animator.gd`)
Currently creates **placeholder** walk animation (just bouncing):
```gdscript
func _create_walk_animation() -> void:
    var anim = Animation.new()
    anim.length = 0.4
    anim.loop_mode = Animation.LOOP_LINEAR
    
    # Placeholder: bouncing effect (NOT sprite frames)
    if sprite:
        var track = anim.add_track(Animation.TYPE_VALUE)
        anim.track_set_path(track, "Sprite2D:position:y")
        # ... keyframes for bounce
    
    _add_animation("walk", anim)
```

---

## How to Create a Real Walk Animation

### Option A: Use AnimationPlayer in Godot Editor (Recommended)

1. **Open** `scenes/characters/player/player.tscn` in Godot
2. **Select** the `AnimationPlayer` node
3. **Create new animation** called `walk` (or edit existing)
4. **Add track:** `Sprite2D:region_rect`
5. **Add keyframes** for each walk frame from your sprite sheet:
   - Frame 1: `Rect2(x1, y1, width, height)`
   - Frame 2: `Rect2(x2, y2, width, height)`
   - etc.
6. **Set loop mode** to Linear
7. **Set animation length** (e.g., 0.4 seconds for 4 frames)

### Option B: Modify CharacterAnimator to Use Sprite Frames

Replace the placeholder in `character_animator.gd`:

```gdscript
func _create_walk_animation() -> void:
    var anim = Animation.new()
    anim.length = 0.4  # Total animation time
    anim.loop_mode = Animation.LOOP_LINEAR
    
    if sprite:
        var track = anim.add_track(Animation.TYPE_VALUE)
        anim.track_set_path(track, "Sprite2D:region_rect")
        
        # Define frame regions from your sprite sheet
        # Adjust these Rect2 values to match your walk frames
        var frame_time = 0.1  # Time per frame
        anim.track_insert_key(track, 0.0, Rect2(0, 0, 40, 42))      # Walk frame 1
        anim.track_insert_key(track, 0.1, Rect2(40, 0, 40, 42))     # Walk frame 2
        anim.track_insert_key(track, 0.2, Rect2(80, 0, 40, 42))     # Walk frame 3
        anim.track_insert_key(track, 0.3, Rect2(120, 0, 40, 42))    # Walk frame 4
    
    _add_animation("walk", anim)
```

### Option C: Use Hframes/Vframes + frame property

1. Set `Sprite2D.hframes` and `Sprite2D.vframes` to match sprite sheet grid
2. Animate `Sprite2D:frame` property instead of `region_rect`
3. Disable `region_enabled`

```gdscript
# In character_animator.gd
func _create_walk_animation() -> void:
    var anim = Animation.new()
    anim.length = 0.4
    anim.loop_mode = Animation.LOOP_LINEAR
    
    if sprite:
        var track = anim.add_track(Animation.TYPE_VALUE)
        anim.track_set_path(track, "Sprite2D:frame")
        
        # Assuming walk frames are frames 4, 5, 6, 7 in the sprite sheet
        anim.track_insert_key(track, 0.0, 4)
        anim.track_insert_key(track, 0.1, 5)
        anim.track_insert_key(track, 0.2, 6)
        anim.track_insert_key(track, 0.3, 7)
    
    _add_animation("walk", anim)
```

---

## Current Sprite2D Properties

From `player.tscn`:
```
position = Vector2(0, -48)
scale = Vector2(4, 4)
texture = "Megan Sprite Sheet Updated.png"
region_enabled = true
region_rect = Rect2(323.31232, 26.518478, 39.82489, 42.36689)
```

The sprite uses **region_rect** to select a portion of the sprite sheet. To animate, you change the region_rect (or switch to frame-based animation).

---

## Animation Timing Reference

For fighting games at 60 FPS:
- 1 frame = 16.67ms = 0.01667 seconds
- 4-frame walk cycle = 0.067 seconds (very fast)
- 8-frame walk cycle = 0.133 seconds
- Typical walk animation = 0.3 - 0.5 seconds per cycle

---

## What You Need to Provide

To create the walk animation, you'll need:

1. **Frame coordinates** from your sprite sheet:
   - X, Y position of each walk frame
   - Width and height of each frame
   - Number of frames in the walk cycle

2. **Desired timing:**
   - How long each frame should display
   - Total animation length

---

## Files to Modify

| File | Purpose |
|------|---------|
| `scripts/characters/character_animator.gd` | Modify `_create_walk_animation()` for programmatic approach |
| `scenes/characters/player/player.tscn` | Edit AnimationPlayer directly in Godot for visual approach |
| `scenes/characters/player/player.tscn` (Sprite2D) | May need to adjust `hframes`/`vframes` or `region_rect` |

---

## Quick Start Prompt for ChatGPT

> "I have a 2D fighting game in Godot 4.5. My sprite sheet is loaded and I'm using region_rect to display frames. I want to create a walk animation that cycles through walk frames. The Sprite2D is at scale 4x, region_enabled is true, and I have an AnimationPlayer. How do I set up the walk animation to cycle through frames at coordinates [provide your frame X,Y,W,H values]?"
