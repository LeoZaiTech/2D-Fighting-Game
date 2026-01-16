class_name BaseCharacter
extends CharacterBody2D
## Base class for all fighting game characters
## Handles physics, facing direction, and common functionality

signal hit_taken(hit_data: Dictionary)
signal state_changed(new_state: String)

@export var move_speed: float = 300.0
@export var jump_force: float = 500.0
@export var gravity: float = 1200.0

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Hurtbox = $Hurtbox

var facing_direction: int = 1  # 1 = right, -1 = left
var hitstun_remaining: int = 0
var is_controllable: bool = true

func _ready() -> void:
	_setup_hurtbox()
	_connect_signals()

func _setup_hurtbox() -> void:
	if hurtbox:
		hurtbox.owner_character = self
		hurtbox.hit_received.connect(_on_hurtbox_hit)

func _connect_signals() -> void:
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if hitstun_remaining > 0:
		hitstun_remaining -= 1
	
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func set_facing(direction: int) -> void:
	if direction == 0:
		return
	facing_direction = sign(direction)
	if sprite:
		sprite.flip_h = facing_direction < 0

func face_opponent(opponent_position: Vector2) -> void:
	var dir = sign(opponent_position.x - global_position.x)
	set_facing(dir)

func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func _on_hurtbox_hit(hit_data: Dictionary) -> void:
	hit_taken.emit(hit_data)
	
	# Apply hitstun
	hitstun_remaining = hit_data.get("hitstun_frames", 0)
	
	# Apply knockback
	var knockback = hit_data.get("knockback", Vector2.ZERO)
	var direction = hit_data.get("direction", 1)
	velocity = Vector2(knockback.x * direction, knockback.y)
	
	# Transition to hitstun state
	if state_machine:
		state_machine.transition_to("hitstun", hit_data)

func _on_animation_finished(anim_name: String) -> void:
	if state_machine and state_machine.current_state:
		state_machine.current_state.on_animation_finished(anim_name)

func is_in_hitstun() -> bool:
	return hitstun_remaining > 0

func get_state_name() -> String:
	if state_machine and state_machine.current_state:
		return state_machine.current_state.name
	return ""
