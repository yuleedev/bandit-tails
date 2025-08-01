extends CanvasLayer

@onready var punishment_label: Label = $Punishment

func _ready():
	hud.visible = false
	

func show_punishment_label(time_left: float) -> void:
	punishment_label.text = "You were caught! You can move again in " + str(time_left) + " seconds."
	punishment_label.visible = true
	
func hide_punishment_label() -> void:
	punishment_label.visible = false
