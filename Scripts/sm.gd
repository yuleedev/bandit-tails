extends Node

## ================ [ FIELDS ] ================ ##

var peer: ENetMultiplayerPeer

## ================ [ HELPERS ] ================ ##

func is_same_client(a: Node, b: Node):
	return a.get_multiplayer_authority() == b.get_multiplayer_authority()

## ================ [ METHODS ] ================ ##

func host_game(port: int) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 2)
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

func join_game(ip: String, port: int) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

@rpc
func send_player_info(p1_id: int, p2_id: int) -> void:
	GM.p1_id = p1_id
	GM.p2_id = p2_id

## ================ [ SIGNALS ] ================ ##

func _on_peer_connected(id: int) -> void:
	if multiplayer.get_unique_id() == 1:
		if GM.p2_id == 0:
			GM.p2_id = id
		elif GM.p1_id == 0:
			GM.p1_id = id
		send_player_info.rpc_id(id, GM.p1_id, GM.p2_id)

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.get_unique_id() == 1:
		if GM.p2_id == id:
			GM.p2_id = 0
			print("Player 2 disconnected")
		elif GM.p1_id == id:
			GM.p1_id = 0
			print("Player 1 disconnected")
	else:
		print("Opponent disconnected. Returning to menu...")
		GM.end_game()

func _on_connected_to_server() -> void:
	print("Successfully connected to server")

func _on_connection_failed() -> void:
	print("ERROR: Failed to connect to server")
	push_error("Connection failed. Please check the IP address and try again.")
	# Return to menu
	get_tree().change_scene_to_file("res://menu.tscn")

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
