extends TextureButton

func _on_ready_button_pressed() -> void:
	print("ready button pressed")
	GM.round += 1
	GM.new_round()
