extends Node

## ================ [ FIELDS ] ================ ##

@export var options: Options = Options.new()
@export var ROUND_DURATION: float = 30

var round: int = 0
var round_dur: float = 0

var game_paused: bool = true
var mouse_captured: bool = false
var keys = 0

var p1_id: int = 1
var p2_id: int

## ================ [ METHODS ] ================ ##

@rpc("call_local")
func start_game() -> void:
	get_tree().change_scene_to_file("res://Levels/main.tscn")
	print("GAME STARTED")

func end_game() -> void:
	get_tree().change_scene_to_file("res://Levels/Menus/hostjoin.tscn")

func new_round() -> void:
	round += 1
	print("new round called")
	print("the current round is " + str(round))
	
	if round > 3:
		end_game()
		
	else:
		if get_tree().current_scene.scene_file_path != "res://Levels/main.tscn":
			get_tree().change_scene_to_file("res://Levels/main.tscn")
		round_dur = ROUND_DURATION
		game_paused = false
		
func end_round() -> void:
	game_paused = true
	print("round end")
	get_tree().change_scene_to_file("res://postround.tscn")

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
	
		if round_dur < 0:
			end_round()

func _input(event: InputEvent) -> void:
	if event.is_action("escape") and event.is_pressed():
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()
