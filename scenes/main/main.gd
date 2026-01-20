extends Node2D
## Main scene controller
## Handles debug display and scene management

@onready var debug_label: Label = $UI/DebugLabel
@onready var dummy: TrainingDummy = $Dummy
@onready var player_spawn: Marker2D = $PlayerSpawn

var player: BaseCharacter = null

func _ready() -> void:
	_spawn_selected_character()
	
	# Make player face the dummy
	if player and dummy:
		player.face_opponent(dummy.global_position)
		dummy.face_opponent(player.global_position)

func _spawn_selected_character() -> void:
	var char_path = GameManager.character_scenes.get(GameManager.selected_character, "")
	if char_path.is_empty():
		char_path = "res://scenes/characters/player/player.tscn"
	
	var char_scene = load(char_path)
	if char_scene:
		player = char_scene.instantiate()
		add_child(player)
		if player_spawn:
			player.global_position = player_spawn.global_position
		else:
			player.global_position = Vector2(300, 620)
		GameManager.register_player(player)

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
