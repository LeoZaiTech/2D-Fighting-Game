class_name CharacterAnimator
extends Node
## Handles animation setup for characters using sprite sheets
## Attach to a character to programmatically create animations

@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer
@export var hitbox: Hitbox

# Frame timing (60 FPS standard for fighting games)
const FRAME_TIME: float = 1.0 / 60.0

func _ready() -> void:
	_setup_placeholder_animations()

func _setup_placeholder_animations() -> void:
	if not animation_player:
		return
	
	# Create animation library if it doesn't exist
	if not animation_player.has_animation_library(""):
		animation_player.add_animation_library("", AnimationLibrary.new())
	
	_create_idle_animation()
	_create_walk_animation()
	_create_jump_animation()
	_create_light_attack_animation()
	_create_hitstun_animation()

func _create_idle_animation() -> void:
	var anim = Animation.new()
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Placeholder: slight bobbing effect
	if sprite:
		var track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, "Sprite2D:position:y")
		anim.track_insert_key(track, 0.0, -48)
		anim.track_insert_key(track, 0.5, -50)
		anim.track_insert_key(track, 1.0, -48)
	
	_add_animation("idle", anim)

func _create_walk_animation() -> void:
	var anim = Animation.new()
	anim.length = 0.4
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Placeholder: bouncing effect
	if sprite:
		var track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, "Sprite2D:position:y")
		anim.track_insert_key(track, 0.0, -48)
		anim.track_insert_key(track, 0.1, -52)
		anim.track_insert_key(track, 0.2, -48)
		anim.track_insert_key(track, 0.3, -52)
		anim.track_insert_key(track, 0.4, -48)
	
	_add_animation("walk", anim)

func _create_jump_animation() -> void:
	var anim = Animation.new()
	anim.length = 0.5
	anim.loop_mode = Animation.LOOP_NONE
	
	# Placeholder: stretch effect
	if sprite:
		var track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, "Sprite2D:scale")
		anim.track_insert_key(track, 0.0, Vector2(2, 2))
		anim.track_insert_key(track, 0.1, Vector2(1.8, 2.3))
		anim.track_insert_key(track, 0.5, Vector2(2, 2))
	
	_add_animation("jump", anim)

func _create_light_attack_animation() -> void:
	var anim = Animation.new()
	anim.length = 0.3  # 18 frames at 60fps
	anim.loop_mode = Animation.LOOP_NONE
	
	# Startup: frames 0-4 (no hitbox)
	# Active: frames 5-10 (hitbox active)
	# Recovery: frames 11-17 (no hitbox)
	
	var startup = 5 * FRAME_TIME
	var active_end = 11 * FRAME_TIME
	
	# Hitbox activation via method calls
	if hitbox:
		var method_track = anim.add_track(Animation.TYPE_METHOD)
		anim.track_set_path(method_track, "Hitbox")
		anim.track_insert_key(method_track, startup, {"method": "activate", "args": []})
		anim.track_insert_key(method_track, active_end, {"method": "deactivate", "args": []})
	
	# Visual feedback: lunge forward
	if sprite:
		var pos_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(pos_track, "Sprite2D:position:x")
		anim.track_insert_key(pos_track, 0.0, 0)
		anim.track_insert_key(pos_track, startup, 15)
		anim.track_insert_key(pos_track, active_end, 15)
		anim.track_insert_key(pos_track, 0.3, 0)
	
	_add_animation("light_attack", anim)
	
	# Also create jump attack
	var jump_anim = anim.duplicate()
	_add_animation("jump_attack", jump_anim)

func _create_hitstun_animation() -> void:
	var anim = Animation.new()
	anim.length = 0.2
	anim.loop_mode = Animation.LOOP_NONE
	
	# Placeholder: shake/flash effect
	if sprite:
		var track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, "Sprite2D:position:x")
		anim.track_insert_key(track, 0.0, 0)
		anim.track_insert_key(track, 0.03, 5)
		anim.track_insert_key(track, 0.06, -5)
		anim.track_insert_key(track, 0.09, 5)
		anim.track_insert_key(track, 0.12, -5)
		anim.track_insert_key(track, 0.2, 0)
		
		var color_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(color_track, "Sprite2D:modulate")
		anim.track_insert_key(color_track, 0.0, Color.WHITE)
		anim.track_insert_key(color_track, 0.05, Color.RED)
		anim.track_insert_key(color_track, 0.1, Color.WHITE)
	
	_add_animation("hitstun", anim)

func _add_animation(name: String, anim: Animation) -> void:
	var lib = animation_player.get_animation_library("")
	if lib and not lib.has_animation(name):
		lib.add_animation(name, anim)
