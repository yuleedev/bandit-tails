extends Player
class_name Raccoon

## ================ [ FIELDS ] ================ ##

@export var DASH_ABILITY: float = 50

## ================ [ PLAYER ] ================ ##

func use_skill() -> void:
	print("raccoon skill")
	velocity = move_dir * DASH_ABILITY
