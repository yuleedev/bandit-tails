extends Button


func _ready() -> void:
	SM.room_code_ready.connect(_on_room_code_ready)
	SM.connection_error.connect(_on_connection_error)


func _process(_delta: float) -> void:
	if GM.p1_id and GM.p2_id:
		disabled = true


func _on_host_pressed() -> void:
	print("hosting...")
	text = "Hosting..."
	disabled = true
	SM.host_game()


func _on_room_code_ready(code: String) -> void:
	# Share this code with the other player so they can join.
	text = "Code: " + code


func _on_connection_error(_reason: String) -> void:
	text = "Host Game"
	disabled = false
