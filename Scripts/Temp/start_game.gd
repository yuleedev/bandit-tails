extends Button

func _on_pressed() -> void:
	GM.start_game.rpc()
