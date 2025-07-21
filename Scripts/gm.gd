extends Node

## ================ [ FIELDS ] ================ ##

@export var options: Options = Options.new()

var mouse_captured: bool = false

## ================ [ METHODS ] ================ ##

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	capture_mouse()

func _input(event: InputEvent) -> void:
	if event.is_action("escape") and event.is_pressed():
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()
