extends Node
## Global game manager autoload
## Handles game state, pause, and global combat events

signal combat_hit(attacker: Node, defender: Node, hit_data: Dictionary)
signal character_defeated(character: Node)

enum GameState { PLAYING, PAUSED, ROUND_START, ROUND_END }

var current_state: GameState = GameState.PLAYING
var player_character: Node = null
var training_dummy: Node = null

# Character selection
var selected_character: String = "megaman"

# Character scene paths
var character_scenes: Dictionary = {
	"megaman": "res://scenes/characters/player/player.tscn",
	"ryu": "res://scenes/characters/player2/player2.tscn"
}

# Frame counter for deterministic combat
var frame_count: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	if current_state == GameState.PLAYING:
		frame_count += 1

func register_player(player: Node) -> void:
	player_character = player

func register_dummy(dummy: Node) -> void:
	training_dummy = dummy

func emit_hit(attacker: Node, defender: Node, hit_data: Dictionary) -> void:
	combat_hit.emit(attacker, defender, hit_data)

func pause_game() -> void:
	current_state = GameState.PAUSED
	get_tree().paused = true

func resume_game() -> void:
	current_state = GameState.PLAYING
	get_tree().paused = false

func reset_frame_count() -> void:
	frame_count = 0
