extends TextureButton

func _process(_delta: float) -> void:
	disabled = multiplayer.get_unique_id() != 1 or GM.p1_id == 0 or GM.p2_id == 0

func _on_host_start_pressed() -> void:
	print("pressed start")
	GM.select_char.rpc()
