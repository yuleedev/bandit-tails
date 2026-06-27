extends Button

func _ready():
	GM.wire_ui_sounds(self)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
