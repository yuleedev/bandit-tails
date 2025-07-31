extends Button

func _on_host_pressed() -> void:
	print("hosted")
	SM.host_game(1234)
	disabled = true
