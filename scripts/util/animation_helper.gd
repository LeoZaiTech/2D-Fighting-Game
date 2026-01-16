class_name AnimationHelper
extends RefCounted
## Utility class for creating fighting game animations programmatically
## Use this to set up animations that control hitbox activation on specific frames

static func create_attack_animation(
	anim_player: AnimationPlayer,
	anim_name: String,
	duration: float,
	hitbox_path: String,
	active_start: float,
	active_end: float
) -> void:
	var animation = Animation.new()
	animation.length = duration
	
	# Track for hitbox activation (calls activate/deactivate methods)
	var method_track = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, hitbox_path)
	
	# Activate hitbox
	animation.track_insert_key(method_track, active_start, {
		"method": "activate",
		"args": []
	})
	
	# Deactivate hitbox
	animation.track_insert_key(method_track, active_end, {
		"method": "deactivate",
		"args": []
	})
	
	var lib = anim_player.get_animation_library("")
	if lib:
		lib.add_animation(anim_name, animation)

static func create_loop_animation(
	anim_player: AnimationPlayer,
	anim_name: String,
	duration: float
) -> void:
	var animation = Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR
	
	var lib = anim_player.get_animation_library("")
	if lib:
		lib.add_animation(anim_name, animation)
