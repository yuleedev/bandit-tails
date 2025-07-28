extends Node3D

@onready var spawner: MultiplayerSpawner = $Spawner

@export var PLAYER_1: PackedScene
@export var SPAWN_1 := Vector3(-3.5, 1, 10)

@export var PLAYER_2: PackedScene
@export var SPAWN_2 := Vector3(-1.5, 1, 10)

@onready var spawn_points = $LootSpawns.get_children()

## ================ [ METHODS ] ================ ##

func _spawn(id: int) -> Player:
	if id == GM.p1_id:
		var player: Player = PLAYER_1.instantiate()
		player.name = str(id)
		player.position = SPAWN_1
		
		player.set_multiplayer_authority(id)
		return player
	else:
		var player: Player = PLAYER_2.instantiate()
		player.name = str(id)
		player.position = SPAWN_2
		
		player.set_multiplayer_authority(id)
		return player

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	spawner.spawn_function = _spawn
	
	if multiplayer.is_server():
		spawner.spawn(GM.p1_id)
		spawner.spawn(GM.p2_id)
	
	GM.new_round()
	GM.capture_mouse()
