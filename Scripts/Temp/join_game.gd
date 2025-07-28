extends Button

func _on_pressed() -> void:
	SM.join_game("127.0.0.1", 1234)
