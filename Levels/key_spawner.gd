extends Node3D

@export var key_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for marker in get_children():
		if marker is Marker3D:
			var key = key_scene.instantiate()
			key.global_transform.origin = key.global_transform.origin
			add_child(key)
