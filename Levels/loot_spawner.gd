extends Node3D

@export var loot_scene: PackedScene
@onready var spawner: MultiplayerSpawner = $Spawner

func _ready() -> void:
	spawner.spawn_function = _spawn_loot
	spawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		initialize_spawning()

func initialize_spawning():
	if not multiplayer.is_server():
		print("no")
		return
	for marker in get_children():
		if marker is Marker3D:
			var spawn_data = {
			"position": marker.global_position, 
			"peer_id": 1,
			"seed": randi()
			}
			spawner.spawn(spawn_data)


func _spawn_loot(data: Dictionary) -> Node:
	var loot = loot_scene.instantiate()
	loot.position = data.position
	loot.name = "Loot_%d_%d" % [data.seed, multiplayer.get_unique_id()]
	loot.set_multiplayer_authority(data.peer_id)
	loot.visible = true
	loot.process_mode = Node.PROCESS_MODE_INHERIT
	return loot
