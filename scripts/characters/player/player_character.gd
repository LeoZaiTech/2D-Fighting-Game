class_name PlayerCharacter
extends BaseCharacter
## Player-controlled fighting game character
## Reads input from InputBuffer autoload

func _ready() -> void:
	super._ready()
	if GameManager:
		GameManager.register_player(self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func get_input_direction() -> int:
	return InputBuffer.get_direction()

func is_jump_buffered() -> bool:
	return InputBuffer.has_buffered_input("jump")

func consume_jump() -> bool:
	return InputBuffer.consume_input("jump")

func is_attack_buffered() -> bool:
	return InputBuffer.has_buffered_input("light_attack")

func consume_attack() -> bool:
	return InputBuffer.consume_input("light_attack")
