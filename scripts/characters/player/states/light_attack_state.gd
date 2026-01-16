class_name LightAttackState
extends BaseState
## Character light attack state - basic attack with hitbox activation

var is_aerial: bool = false
var attack_finished: bool = false
var hitbox: Hitbox

func enter(params: Dictionary = {}) -> void:
	if not hitbox:
		hitbox = character.get_node_or_null("Hitbox")
	is_aerial = params.get("aerial", false)
	attack_finished = false
	
	if is_aerial:
		character.play_animation("jump_attack")
	else:
		character.play_animation("light_attack")
		character.velocity.x = 0

func physics_update(_delta: float) -> void:
	# If aerial, still apply gravity movement
	if is_aerial:
		var player = character as PlayerCharacter
		if player and is_grounded():
			# Landed during aerial attack
			state_machine.transition_to("idle")
			return
	
	# Attack completion is handled by animation_finished signal

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "light_attack" or anim_name == "jump_attack":
		attack_finished = true
		if is_grounded():
			state_machine.transition_to("idle")
		else:
			state_machine.transition_to("jump")

func exit() -> void:
	# Ensure hitbox is deactivated
	if hitbox:
		hitbox.deactivate()

func can_be_interrupted() -> bool:
	# Attacks cannot be interrupted (except by hitstun)
	return false
