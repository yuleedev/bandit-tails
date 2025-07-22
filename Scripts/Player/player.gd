extends CharacterBody3D

## ================ [ FIELDS ] ================ ##

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera
@onready var light: SpotLight3D = $Pivot/Camera/Light

@export var MOVE_SPEED: float = 5

var input_dir: Vector2
var move_dir: Vector3

var mouse_motion: Vector2

## ================ [ METHODS ] ================ ##

func _rotate_camera(delta: float) -> void:
	pivot.rotation.y -= mouse_motion.x * delta
	camera.rotation.x -= mouse_motion.y * delta
	camera.rotation.x = clamp(camera.rotation.x, -PI/2 + Math.NONZERO, PI/3)
	
	mouse_motion = Vector2.ZERO

func _apply_movement() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	move_dir = (
		pivot.transform.basis * Math.to_3d(input_dir)
	).normalized()
	
	velocity = move_dir * MOVE_SPEED

## ================ [ GODOT ] ================ ##

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.screen_relative

func _process(delta: float) -> void:
	_rotate_camera(delta)
	_apply_movement()

func _physics_process(_delta: float) -> void:
	move_and_slide()
