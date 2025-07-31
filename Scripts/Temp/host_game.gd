extends Button


func _process(_delta: float) -> void:
	if GM.p1_id and GM.p2_id:
		disabled = true

func _on_host_pressed() -> void:
	print("hosted")
	SM.host_game(1234)
	disabled = true
