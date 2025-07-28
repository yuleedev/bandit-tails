extends Node3D

@onready var spawn_points = $LootSpawns.get_children()

func _ready():
	GM.new_round()
