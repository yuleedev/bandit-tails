extends TextureButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GM.wire_ui_sounds(self)
	if multiplayer.get_unique_id() == GM.p1_id:
			visible = true

func _on_ready_button_pressed() -> void:
	GM.round += 1
	print("ready button pressed")
	GM.rpc("new_round")
	print("new round sent")
