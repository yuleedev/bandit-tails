extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GM.play_menu_music()
	GM.wire_ui_sounds(self)

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/hostjoin.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial.tscn")
