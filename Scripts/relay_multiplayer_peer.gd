class_name RelayMultiplayerPeer
extends MultiplayerPeerExtension

## Tunnels Godot's high-level multiplayer through the cloud relay (relay/relay.js)
## via a short room code instead of an IP. Host is peer 1, guest is peer 2, so
## the rest of the game is unchanged. Works in native and web exports.

enum Role { NONE, HOST, CLIENT }

const SERVER_ID := 1
const GUEST_ID := 2

const MAX_RETRIES := 20
const RETRY_DELAY_MS := 3000

## Emitted when the relay assigns this host its room code (HOST only).
signal code_received(code: String)
## Emitted when the connection cannot be established (bad code, relay down, ...).
signal error_occurred(reason: String)

var room_code: String = ""

var _socket := WebSocketPeer.new()
var _role: int = Role.NONE
var _status: int = MultiplayerPeer.CONNECTION_DISCONNECTED
var _unique_id: int = 0
var _target_peer: int = 0
var _transfer_mode: int = MultiplayerPeer.TRANSFER_MODE_RELIABLE
var _transfer_channel: int = 0
var _refuse_connections: bool = false

var _url: String = ""
var _retry_count: int = 0
var _reconnect_at_ms: int = 0

var _join_code: String = ""
var _handshake_sent: bool = false
var _guest_connected: bool = false

var _incoming: Array = []

## ================ [ PUBLIC ] ================ ##

func host(url: String) -> void:
	_role = Role.HOST
	_unique_id = SERVER_ID
	_status = MultiplayerPeer.CONNECTION_CONNECTING
	_start(url)

func join(url: String, code: String) -> void:
	_role = Role.CLIENT
	_unique_id = GUEST_ID
	_join_code = code.strip_edges().to_upper()
	_status = MultiplayerPeer.CONNECTION_CONNECTING
	_start(url)

func _start(url: String) -> void:
	_url = url
	_retry_count = 0
	_reconnect_at_ms = 0
	_open_socket()

func _open_socket() -> void:
	_socket = WebSocketPeer.new()
	_socket.inbound_buffer_size = 1 << 20
	_socket.outbound_buffer_size = 1 << 20
	_socket.max_queued_packets = 4096
	_handshake_sent = false
	var err := _socket.connect_to_url(_url)
	if err != OK:
		_schedule_retry_or_fail()

# Free hosting tiers sleep when idle and drop the first connection while waking;
# retry quietly until MAX_RETRIES before reporting failure.
func _schedule_retry_or_fail() -> void:
	if _retry_count < MAX_RETRIES:
		_retry_count += 1
		_reconnect_at_ms = Time.get_ticks_msec() + RETRY_DELAY_MS
	else:
		_status = MultiplayerPeer.CONNECTION_DISCONNECTED
		error_occurred.emit("connect_failed")

## ================ [ RELAY PROTOCOL ] ================ ##

func _send_handshake() -> void:
	if _role == Role.HOST:
		_socket.send_text(JSON.stringify({"action": "host"}))
	elif _role == Role.CLIENT:
		_socket.send_text(JSON.stringify({"action": "join", "code": _join_code}))

func _handle_control(text: String) -> void:
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return
	match String(data.get("type", "")):
		"hosted":
			room_code = String(data.get("code", ""))
			_status = MultiplayerPeer.CONNECTION_CONNECTED
			code_received.emit(room_code)
		"peer_joined":
			if not _guest_connected:
				_guest_connected = true
				peer_connected.emit(GUEST_ID)
		"peer_left":
			if _guest_connected:
				_guest_connected = false
				peer_disconnected.emit(GUEST_ID)
		"joined":
			_status = MultiplayerPeer.CONNECTION_CONNECTED
			peer_connected.emit(SERVER_ID)
		"host_left":
			if _status == MultiplayerPeer.CONNECTION_CONNECTED:
				peer_disconnected.emit(SERVER_ID)
			_status = MultiplayerPeer.CONNECTION_DISCONNECTED
			_socket.close()
		"error":
			error_occurred.emit(String(data.get("reason", "unknown")))
			_status = MultiplayerPeer.CONNECTION_DISCONNECTED
			_socket.close()

func _handle_socket_closed() -> void:
	if _status == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	# Dropped before reaching the host => likely a cold-starting relay, so retry.
	if _status == MultiplayerPeer.CONNECTION_CONNECTING and _reconnect_at_ms == 0:
		_schedule_retry_or_fail()
		return
	var was_connected := _status == MultiplayerPeer.CONNECTION_CONNECTED
	_status = MultiplayerPeer.CONNECTION_DISCONNECTED
	if _role == Role.CLIENT:
		if was_connected:
			peer_disconnected.emit(SERVER_ID)
	elif _role == Role.HOST:
		if _guest_connected:
			_guest_connected = false
			peer_disconnected.emit(GUEST_ID)

## ================ [ MultiplayerPeerExtension OVERRIDES ] ================ ##

func _poll() -> void:
	if _role == Role.NONE:
		return
	if _reconnect_at_ms != 0:
		if Time.get_ticks_msec() >= _reconnect_at_ms:
			_reconnect_at_ms = 0
			_open_socket()
		return
	_socket.poll()
	match _socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not _handshake_sent:
				_send_handshake()
				_handshake_sent = true
			while _socket.get_available_packet_count() > 0:
				var pkt := _socket.get_packet()
				if _socket.was_string_packet():
					_handle_control(pkt.get_string_from_utf8())
				else:
					var from_id := GUEST_ID if _role == Role.HOST else SERVER_ID
					_incoming.push_back({"peer": from_id, "bytes": pkt})
		WebSocketPeer.STATE_CLOSED:
			_handle_socket_closed()

func _put_packet_script(buffer: PackedByteArray) -> Error:
	if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return ERR_UNAVAILABLE
	return _socket.send(buffer, WebSocketPeer.WRITE_MODE_BINARY)

func _get_packet_script() -> PackedByteArray:
	if _incoming.is_empty():
		return PackedByteArray()
	var item: Dictionary = _incoming.pop_front()
	return item["bytes"]

func _get_available_packet_count() -> int:
	return _incoming.size()

# Engine reads the sender id before popping the packet, so peek at the head.
func _get_packet_peer() -> int:
	if _incoming.is_empty():
		return 1
	return _incoming[0]["peer"]

func _get_packet_mode() -> int:
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE

func _get_packet_channel() -> int:
	return 0

func _set_target_peer(peer: int) -> void:
	_target_peer = peer

func _is_server() -> bool:
	return _role == Role.HOST

func _get_unique_id() -> int:
	return _unique_id

func _get_connection_status() -> int:
	return _status

func _get_max_packet_size() -> int:
	return 1 << 24

func _set_transfer_channel(channel: int) -> void:
	_transfer_channel = channel

func _get_transfer_channel() -> int:
	return _transfer_channel

func _set_transfer_mode(mode: int) -> void:
	_transfer_mode = mode

func _get_transfer_mode() -> int:
	return _transfer_mode

func _set_refuse_new_connections(enable: bool) -> void:
	_refuse_connections = enable

func _is_refusing_new_connections() -> bool:
	return _refuse_connections

func _is_server_relay_supported() -> bool:
	return true

func _disconnect_peer(_peer: int, _force: bool) -> void:
	# Our only link is to the relay; closing it would drop us too, so leave
	# teardown to _close().
	pass

func _close() -> void:
	var state := _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN or state == WebSocketPeer.STATE_CONNECTING:
		_socket.close()
	_status = MultiplayerPeer.CONNECTION_DISCONNECTED
	_incoming.clear()
	_guest_connected = false
	_role = Role.NONE
