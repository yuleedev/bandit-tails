extends CharacterBody3D

## ================ [ FIELDS ] ================ ##

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera
@onready var light: SpotLight3D = $Pivot/Light

@export var MOVE_SPEED: float = 5

var input_dir: Vector2
var move_dir: Vector3

## ================ [ GODOT ] ================ ##

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot.rotation.y -= event.relative.x * GM.options.MOUSE_SENSITIVITY
		camera.rotation.x -= event.relative.y * GM.options.MOUSE_SENSITIVITY
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/3)

func _process(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	move_dir = (
		pivot.transform.basis * Math.to_3d(input_dir)
	).normalized()
	
	velocity = move_dir * MOVE_SPEED

func _physics_process(delta: float) -> void:
	move_and_slide()
