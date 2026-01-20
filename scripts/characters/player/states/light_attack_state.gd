class_name LightAttackState
extends BaseState
## Character light attack state - basic attack with hitbox activation

var is_aerial: bool = false
var attack_finished: bool = false
var hitbox: Hitbox
var combo_count: int = 0
var combo_buffered: bool = false
const MAX_COMBO: int = 2

func enter(params: Dictionary = {}) -> void:
	if not hitbox:
		hitbox = character.get_node_or_null("Hitbox")
	is_aerial = params.get("aerial", false)
	combo_count = params.get("combo", 0)
	attack_finished = false
	combo_buffered = false
	
	if is_aerial:
		character.play_animation("jump_attack")
	else:
		# Play different animation based on combo count
		if combo_count == 0:
			character.play_animation("light_attack")
		else:
			character.play_animation("light_attack_2")
		character.velocity.x = 0

func physics_update(_delta: float) -> void:
	# If aerial, still apply gravity movement
	if is_aerial:
		var player = character as PlayerCharacter
		if player and is_grounded():
			state_machine.transition_to("idle")
			return
	
	# Check for combo input (buffer the next attack)
	if not combo_buffered and combo_count < MAX_COMBO - 1:
		if Input.is_action_just_pressed("light_attack"):
			combo_buffered = true

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "light_attack" or anim_name == "light_attack_2" or anim_name == "jump_attack":
		attack_finished = true
		# Chain to next combo if buffered
		if combo_buffered and is_grounded():
			# Re-enter this state for combo (can't transition to same state)
			combo_count += 1
			combo_buffered = false
			character.play_animation("light_attack_2")
		elif is_grounded():
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
