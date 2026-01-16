class_name Hitbox
extends Area2D
## Hitbox component for attacks
## Detects overlaps with Hurtboxes (non-physics based collision detection)

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 10
@export var hitstun_frames: int = 12
@export var knockback_force: Vector2 = Vector2(200, -50)
@export var hit_type: String = "mid"  # low, mid, high, overhead

var owner_character: Node
var is_active: bool = false
var has_hit_this_activation: Array[Node] = []

func _ready() -> void:
	# Hitboxes start disabled
	monitoring = false
	monitorable = false
	
	area_entered.connect(_on_area_entered)

func activate() -> void:
	is_active = true
	monitoring = true
	has_hit_this_activation.clear()

func deactivate() -> void:
	is_active = false
	monitoring = false
	has_hit_this_activation.clear()

func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		
		# Don't hit self
		if hurtbox.owner_character == owner_character:
			return
		
		# Don't hit same target twice in one activation
		if hurtbox.owner_character in has_hit_this_activation:
			return
		
		has_hit_this_activation.append(hurtbox.owner_character)
		
		var hit_data = {
			"damage": damage,
			"hitstun_frames": hitstun_frames,
			"knockback": knockback_force,
			"hit_type": hit_type,
			"attacker": owner_character,
			"direction": sign(hurtbox.global_position.x - global_position.x)
		}
		
		hurtbox.receive_hit(hit_data)
		hit_landed.emit(hurtbox)
		
		if GameManager:
			GameManager.emit_hit(owner_character, hurtbox.owner_character, hit_data)

func get_hit_data() -> Dictionary:
	return {
		"damage": damage,
		"hitstun_frames": hitstun_frames,
		"knockback": knockback_force,
		"hit_type": hit_type
	}
