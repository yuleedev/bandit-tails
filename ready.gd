extends TextureButton

func _on_ready_button_pressed() -> void:
	GM.round += 1
	GM.new_round()
