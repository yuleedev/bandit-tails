extends TextureButton

func _on_ready_button_pressed() -> void:
	print("ready button pressed")
	GM.new_round()
