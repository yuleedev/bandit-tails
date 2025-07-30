extends TextureButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ready_button_pressed() -> void:
	GM.round += 1
	GM.new_round()
