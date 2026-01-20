class_name CharacterSelect
extends Control
## Character selection screen

@onready var char1_btn: Button = $CharacterGrid/Character1/VBox/SelectBtn
@onready var char2_btn: Button = $CharacterGrid/Character2/VBox/SelectBtn
@onready var back_btn: Button = $BackButton

func _ready() -> void:
	char1_btn.pressed.connect(_on_character1_selected)
	char2_btn.pressed.connect(_on_character2_selected)
	back_btn.pressed.connect(_on_back_pressed)
	char1_btn.grab_focus()

func _on_character1_selected() -> void:
	GameManager.selected_character = "megaman"
	_start_game()

func _on_character2_selected() -> void:
	GameManager.selected_character = "ryu"
	_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
