extends Button

func _on_pressed() -> void:
	GM.select_char.rpc()
