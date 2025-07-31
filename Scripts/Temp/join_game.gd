extends LineEdit

func _on_ip_submitted(new_text: String) -> void:
	print(new_text)
	SM.join_game(new_text, 1234)
