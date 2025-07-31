extends LineEdit

func _on_ip_submitted(new_text: String) -> void:
	SM.join_game("169.233.169.186", 1234)
