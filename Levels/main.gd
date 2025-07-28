extends Node3D

@onready var spawn_points = $LootSpawns.get_children()

var loot_scenes = [
	preload("res://Assets/Props/Loot/loot_square.tscn"),
	preload("res://Assets/Props/Loot/loot_cylinder.tscn"),
	preload("res://Assets/Props/Loot/loot_prism.tscn")
]

func _ready():
	GM.new_round()
	spawn_random_loot()

func spawn_random_loot():
	var shuffled_loot = loot_scenes.duplicate()
	shuffled_loot.shuffle()
	
	var shuffled_spawns = spawn_points.duplicate()
	shuffled_spawns.shuffle()

	for i in range(3):
		var loot_instance = shuffled_loot[i].instantiate()
		get_tree().current_scene.add_child(loot_instance)
		loot_instance.global_transform.origin = shuffled_spawns[i].global_transform.origin
