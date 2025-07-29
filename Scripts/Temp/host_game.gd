extends Button

func _on_pressed() -> void:
	SM.host_game(1234)
	disabled = true
