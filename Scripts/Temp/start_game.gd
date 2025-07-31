extends TextureButton

func _on_host_start_pressed() -> void:
	GM.select_char.rpc()
