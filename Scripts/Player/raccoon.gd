extends Player
class_name Raccoon

## ================ [ FIELDS ] ================ ##

@export var DASH_ABILITY: float = 50

## ================ [ PLAYER ] ================ ##
func _ready() -> void:
	pass

func use_skill() -> void:
	velocity = move_dir * DASH_ABILITY
