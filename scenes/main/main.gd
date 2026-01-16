extends Node2D
## Main scene controller
## Handles debug display and scene management

@onready var debug_label: Label = $UI/DebugLabel
@onready var player: PlayerCharacter = $Player
@onready var dummy: TrainingDummy = $Dummy

func _ready() -> void:
	# Make player face the dummy
	if player and dummy:
		player.face_opponent(dummy.global_position)
		dummy.face_opponent(player.global_position)

func _process(_delta: float) -> void:
	_update_debug_display()

func _update_debug_display() -> void:
	if not debug_label or not player:
		return
	
	var state_name = player.get_state_name()
	var velocity = player.velocity
	var hitstun = player.hitstun_remaining
	
	var debug_text = "WASD - Move/Jump | J - Light Attack\n"
	debug_text += "---\n"
	debug_text += "Player State: %s\n" % state_name
	debug_text += "Velocity: (%.0f, %.0f)\n" % [velocity.x, velocity.y]
	debug_text += "Hitstun: %d frames\n" % hitstun
	
	if dummy:
		debug_text += "---\n"
		debug_text += "Dummy State: %s\n" % dummy.get_state_name()
		debug_text += "Dummy Hitstun: %d frames" % dummy.hitstun_remaining
	
	debug_label.text = debug_text
