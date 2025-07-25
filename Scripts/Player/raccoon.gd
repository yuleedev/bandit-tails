extends Player
class_name Raccoon

## ================ [ FIELDS ] ================ ##

@export var DASH_ABILITY: float = 100

## ================ [ PLAYER ] ================ ##

func use_skill() -> void:
	velocity = move_dir * DASH_ABILITY
