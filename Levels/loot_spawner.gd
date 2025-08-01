extends Node3D

@export var loot_scene: PackedScene
@onready var spawner: MultiplayerSpawner = $Spawner

@rpc
func _ready():
	GM.register_spawner(self)

func initialize_spawning():
	if not multiplayer.is_server():
		print("no")
		return
	await get_tree().process_frame
	spawner.spawn_function = _spawn_loot
	spawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		spawner.spawn_function = _spawn_loot.bind()
		for marker in get_children():
			if marker is Marker3D:
				var spawn_data = {
				"position": marker.global_position, 
				"peer_id": 1,
				"seed": randi()
				}
				spawner.spawn(spawn_data)

@rpc
func _spawn_loot(data: Dictionary) -> Node:
	var loot = loot_scene.instantiate()
	loot.position = data.position
	loot.name = "Loot_%d" % data.seed
	loot.set_multiplayer_authority(data.peer_id)
	return loot
