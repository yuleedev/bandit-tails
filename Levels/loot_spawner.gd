extends Node3D

@export var loot_scene: PackedScene

func _ready():
	for marker in get_children():
		if marker is Marker3D:
			var loot = loot_scene.instantiate()
			loot.global_transform.origin = marker.global_transform.origin
			add_child(loot)
