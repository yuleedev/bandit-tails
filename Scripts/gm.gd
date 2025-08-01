extends Node

## ================ [ FIELDS ] ================ ##

@export var options: Options = Options.new()
@export var ROUND_DURATION: float = 50
var loot_spawner: Node = null

var round: int = 1
var round_dur: float = 0
var game_paused: bool = true
var mouse_captured: bool = false
var keys = 0

var p1_id: int = 1
var p2_id: int

## ================ [ METHODS ] ================ ##

@rpc("call_local")
func select_char() -> void:
	get_tree().change_scene_to_file("res://character_select.tscn")

func register_spawner(spawner: Node):
	loot_spawner = spawner
	if multiplayer.is_server() and spawner.has_method("initialize_spawning"):
		spawner.initialize_spawning()

func _print_node_tree(node: Node, indent: String = ""):
	print(indent + node.name)
	for child in node.get_children():
		_print_node_tree(child, indent + "  ")

@rpc("call_local")
func start_game() -> void:
	print("Current scene tree before change:")
	_print_node_tree(get_tree().root)
	get_tree().change_scene_to_file("res://Levels/main.tscn")
	await get_tree().process_frame
	
	if multiplayer.is_server():
		loot_spawner = get_tree().root.find_child("LootSpawner", true, false)
		if loot_spawner:
			loot_spawner.initialize_spawning()
		else:
			push_error("LootSpawner not found after scene change")
	print("\nNew scene tree after change:")


@rpc("call_local")
func end_game() -> void:
	game_paused = true
	get_tree().change_scene_to_file("res://menu.tscn")
	_print_node_tree(get_tree().root)

@rpc
func new_round() -> void:
	await get_tree().process_frame
	
	if get_tree().current_scene.scene_file_path != "res://Levels/main.tscn":
		if !multiplayer.is_server():  
			get_tree().change_scene_to_file("res://Levels/main.tscn")
	
	round_dur = ROUND_DURATION
	game_paused = false

@rpc
func end_round() -> void:
	game_paused = true
	if round < 3:
		get_tree().change_scene_to_file("res://postround.tscn")
	else:
		end_game()

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

## ================ [ GODOT ] ================ ##

func _process(delta: float) -> void:
	if not game_paused:
		round_dur -= delta
	
		if round_dur <= 0:
			end_round()

func _input(event: InputEvent) -> void:
	if event.is_action("escape") and event.is_pressed():
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()
