extends TextureButton

func _on_host_start_pressed() -> void:
	print("pressed start")
	GM.select_char.rpc()
