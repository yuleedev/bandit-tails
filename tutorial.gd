extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GM.play_menu_music()
	GM.wire_ui_sounds(self)

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")
