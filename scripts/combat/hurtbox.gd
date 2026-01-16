class_name Hurtbox
extends Area2D
## Hurtbox component for receiving damage
## Reports hits to the owning character

signal hit_received(hit_data: Dictionary)

var owner_character: Node
var is_active: bool = true

func _ready() -> void:
	monitoring = false
	monitorable = true

func receive_hit(hit_data: Dictionary) -> void:
	if not is_active:
		return
	hit_received.emit(hit_data)

func set_active(active: bool) -> void:
	is_active = active
	monitorable = active
