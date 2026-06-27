extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GM.play_menu_music()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
