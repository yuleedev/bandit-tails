extends Node

## ================ [ FIELDS ] ================ ##

## Public address of the relay server (see relay/relay.js + relay/README.md).
## After you deploy the relay, replace this with your own URL, e.g.
##   "wss://mole-heist-relay.onrender.com"
## Use ws:// (not wss://) only for local testing against `node relay.js`.
const RELAY_URL := "wss://mole-heist-2.onrender.com"

var peer: RelayMultiplayerPeer

## Room code shown to the host so the joiner can type it in.
var room_code: String = ""

## Emitted once the relay hands the host its room code.
signal room_code_ready(code: String)
## Emitted when a host/join attempt fails (relay down, bad code, room full).
signal connection_error(reason: String)
## Emitted on the joiner once it successfully reaches the host.
signal connected_to_host()

## ================ [ HELPERS ] ================ ##

func is_same_client(a: Node, b: Node):
	return a.get_multiplayer_authority() == b.get_multiplayer_authority()

func _relay_configured() -> bool:
	if RELAY_URL.contains("CHANGE-ME"):
		push_warning("SM.RELAY_URL is not set. Deploy relay/ and set RELAY_URL in Scripts/sm.gd.")
		connection_error.emit("relay_not_configured")
		return false
	return true

## ================ [ METHODS ] ================ ##

func host_game() -> void:
	if not _relay_configured():
		return
	room_code = ""
	peer = RelayMultiplayerPeer.new()
	peer.code_received.connect(_on_code_received)
	peer.error_occurred.connect(_on_peer_error)
	peer.host(RELAY_URL)
	multiplayer.multiplayer_peer = peer

func join_game(code: String) -> void:
	if not _relay_configured():
		return
	peer = RelayMultiplayerPeer.new()
	peer.code_received.connect(_on_code_received)
	peer.error_occurred.connect(_on_peer_error)
	peer.join(RELAY_URL, code)
	multiplayer.multiplayer_peer = peer

func _on_code_received(code: String) -> void:
	room_code = code
	room_code_ready.emit(code)

func _on_peer_error(reason: String) -> void:
	connection_error.emit(reason)

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
		elif GM.p1_id == id:
			GM.p1_id = 0
	else:
		if GM.p1_id == id:
			GM.end_game()
		else:
			GM.end_game()

func _on_connected_to_server() -> void:
	print(":)")
	connected_to_host.emit()

func _on_connection_failed() -> void:
	print(":(")

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	multiplayer.allow_object_decoding = true
