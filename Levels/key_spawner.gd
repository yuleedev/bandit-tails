extends Node3D

@export var key_scene: PackedScene
@onready var spawner: MultiplayerSpawner = $Spawner

# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	spawner.spawn_function = _spawn_key
	spawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		initialize_spawning()

func initialize_spawning():
	if not multiplayer.is_server():
		return
	
	var all_markers = []
	for child in get_children():
		if child is Marker3D:
			all_markers.append(child)
	all_markers.shuffle()
	
	for i in range(4):
		var spawn_data = {
		"position": all_markers[i].global_position, 
		"peer_id": 1,
		}
		spawner.spawn(spawn_data)

func _spawn_key(data: Dictionary) -> Node:
	var key = key_scene.instantiate()
	key.position = data.position
	key.set_multiplayer_authority(data.peer_id)
	key.visible = true
	key.process_mode = Node.PROCESS_MODE_INHERIT
	return key
	
