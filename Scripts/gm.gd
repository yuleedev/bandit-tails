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

var p1_round_value: float
var p2_round_value: float
var p1_total_value: float = 0
var p2_total_value: float = 0

var p1_wins: float = 0
var p2_wins: float = 0

## ================ [ METHODS ] ================ ##
@rpc("call_local")
func select_char() -> void:
	get_tree().change_scene_to_file("res://character_select.tscn")

@rpc("call_local")
func start_game() -> void:
	get_tree().change_scene_to_file("res://Levels/main.tscn")
	hud.visible = true
	await get_tree().process_frame

@rpc("call_local")
func show_result_screen(result: String) -> void:
	match result:
		"win":
			get_tree().change_scene_to_file("res://victory.tscn")
		"lose":
			get_tree().change_scene_to_file("res://loss.tscn")
		"tie":
			get_tree().change_scene_to_file("res://tie.tscn")

@rpc("call_local")
func end_game() -> void:
	game_paused = true
	var my_id = multiplayer.get_unique_id()

	if p1_wins > p2_wins:
		if my_id == p1_id:
			show_result_screen.rpc("win")
		else:
			show_result_screen.rpc("lose")
	elif p2_wins > p1_wins:
		if my_id == p2_id:
			show_result_screen.rpc("win")
		else:
			show_result_screen.rpc("lose")
	else:
		show_result_screen.rpc("tie")

@rpc("any_peer", "call_local")
func new_round() -> void:
	
	p1_round_value = 0
	p2_round_value = 0
	
	await get_tree().process_frame
	print("awaited")
	if get_tree().current_scene.scene_file_path != "res://Levels/main.tscn":
		get_tree().change_scene_to_file("res://Levels/main.tscn")
	
	round_dur = ROUND_DURATION
	game_paused = false

@rpc
func end_round() -> void:
	game_paused = true
	hud.visible = false
	
	print("p1's total val: " + str(p1_round_value))
	print("p2's total val: " + str(p2_round_value))
	p1_total_value += p1_round_value
	p2_total_value += p2_round_value
	
	if p1_round_value > p2_round_value:
		p1_wins += 1
	if p2_round_value > p1_round_value:
		p2_wins += 1
	else: 
		pass
	
	
	
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
