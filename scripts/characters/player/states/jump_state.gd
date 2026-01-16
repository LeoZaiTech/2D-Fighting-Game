class_name JumpState
extends BaseState
## Character jump state - airborne movement

var has_left_ground: bool = false

func enter(_params: Dictionary = {}) -> void:
	character.play_animation("jump")
	character.velocity.y = -character.jump_force
	has_left_ground = false

func physics_update(_delta: float) -> void:
	var player = character as PlayerCharacter
	if not player:
		return
	
	# Track if we've left the ground
	if not is_grounded():
		has_left_ground = true
	
	# Check for air attack
	if player.is_attack_buffered():
		player.consume_attack()
		state_machine.transition_to("light_attack", {"aerial": true})
		return
	
	# Allow air control
	var direction = player.get_input_direction()
	player.velocity.x = direction * player.move_speed * 0.8
	
	if direction != 0:
		player.set_facing(direction)
	
	# Land when touching ground after leaving it
	if has_left_ground and is_grounded():
		state_machine.transition_to("idle")

func can_be_interrupted() -> bool:
	return true
