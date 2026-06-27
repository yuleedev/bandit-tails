extends LineEdit


func _ready() -> void:
	placeholder_text = "  Enter room code..."
	SM.connection_error.connect(_on_connection_error)
	SM.connected_to_host.connect(_on_connected_to_host)


func _on_connected_to_host() -> void:
	placeholder_text = "  Connected! Waiting for host..."


func _on_ip_submitted(new_text: String) -> void:
	var code := new_text.strip_edges()
	if code.is_empty():
		return
	print("joining ", code)
	editable = false
	placeholder_text = "  Connecting..."
	SM.join_game(code)


func _on_connection_error(reason: String) -> void:
	editable = true
	text = ""
	match reason:
		"no_room":
			placeholder_text = "  Code not found, try again..."
		"room_full":
			placeholder_text = "  Game is full..."
		"relay_not_configured":
			placeholder_text = "  Relay not set up yet..."
		_:
			placeholder_text = "  Couldn't connect, try again..."
