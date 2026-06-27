extends CanvasLayer

@onready var punishment_label: Label = $Punishment

func _ready():
	hud.visible = false
	

func show_punishment_label(time_left: float) -> void:
	_set_punishment_text(time_left)
	punishment_label.visible = true

func update_punishment_label(time_left: float) -> void:
	_set_punishment_text(time_left)

func _set_punishment_text(time_left: float) -> void:
	var seconds_left: int = int(ceil(time_left))
	var unit := "second" if seconds_left == 1 else "seconds"
	punishment_label.text = "You were caught! You can move again in %d %s." % [seconds_left, unit]

func hide_punishment_label() -> void:
	punishment_label.visible = false
