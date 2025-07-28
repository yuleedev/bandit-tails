extends Node

## ================ [ FIELDS ] ================ ##

@export var options: Options = Options.new()
@export var ROUND_DURATION: float = 180

var round: int = 0
var round_dur: float = 0

var game_paused: bool = true
var mouse_captured: bool = false

## ================ [ METHODS ] ================ ##

func new_round() -> void:
	var player: CharacterBody3D = get_tree().current_scene.get_child(0)
	player.position = Vector3(-2.5, 1, 10)
	
	round += 1
	round_dur = ROUND_DURATION
	game_paused = false

func end_round() -> void:
	game_paused = true
	print("round end")
	# this is where i would switch to between rounds screen but that doesnt exist

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	_capture_mouse()

func _process(delta: float) -> void:
	if not game_paused:
		round_dur -= delta
		
		if round_dur < 0:
			end_round()

func _input(event: InputEvent) -> void:
	if event.is_action("escape") and event.is_pressed():
		if mouse_captured:
			_release_mouse()
		else:
			_capture_mouse()
