class_name TrainingDummy
extends BaseCharacter
## Training dummy that receives hits and displays hitstun

func _ready() -> void:
	super._ready()
	is_controllable = false
	if GameManager:
		GameManager.register_dummy(self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
