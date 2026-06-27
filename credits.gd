extends Control

func _ready():
	GM.play_menu_music()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
