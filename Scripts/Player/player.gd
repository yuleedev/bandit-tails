extends CharacterBody3D
class_name Player

## ================ [ NODES ] ================ ##

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera
@onready var light: SpotLight3D = $Pivot/Camera/Light

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var sound: CollisionShape3D = $SoundArea/Collider

## ================ [ FIELDS ] ================ ##

@export_group("Movement")
@export var MOVE_SPEED: float = 5
@export var ACCELERATION: float = 5

@export_group("Ability")
@export var COOLDOWN: float = 3

var input_dir: Vector2
var move_dir: Vector3
var mouse_motion: Vector2

var cd: float

var interactable: Node3D = null

## ================ [ HELPERS ] ================ ##

func use_skill() -> void:
	pass

## ================ [ METHODS ] ================ ##

func _update_timers(delta: float) -> void:
	if cd > 0:
		cd -= delta

func _rotate_camera() -> void:
	pivot.rotation.y -= mouse_motion.x * GM.options.MOUSE_SENSITIVITY
	camera.rotation.x -= mouse_motion.y * GM.options.MOUSE_SENSITIVITY
	camera.rotation.x = clamp(camera.rotation.x, -PI/2 + Math.NONZERO, PI/3)
	
	mouse_motion = Vector2.ZERO

func _apply_movement() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	move_dir = (
		pivot.transform.basis * Math.to_3d(input_dir)
	).normalized()
	
	velocity = velocity.move_toward(move_dir * MOVE_SPEED, ACCELERATION)

func _manage_interactable() -> void:
	if interactable:
		if interactable.is_in_group("loot") and Input.is_action_pressed("interact"):
			interactable.pick_up()
		elif interactable.is_in_group("door") and Input.is_action_just_pressed("interact"):
			interactable.open()

func _manage_skill() -> void:
	if Input.is_action_just_pressed("skill") and cd <= 0:
		use_skill()
		cd = COOLDOWN

## ================ [ GODOT ] ================ ##

func _process(delta: float) -> void:
	_update_timers(delta)
	
	_rotate_camera()
	_apply_movement()
	
	_manage_interactable()
	_manage_skill()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("loot") or body.is_in_group("door"):
		interactable = body

func _on_body_exited(body):
	if interactable == body:
		interactable = null

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.screen_relative

#adjusts the radius of the sound collision shape
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_0: #when player isn't moving, makes no sound
			print("0 was pressed")
			sound.shape.radius = 0
		if event.keycode == KEY_1: #sneaking
			print("1 was pressed")
			sound.shape.radius = 0.5
		if event.keycode == KEY_2: #normal walking
			print("2 was pressed")
			sound.shape.radius = 1
		if event.keycode == KEY_3: #sprinting
			print("3 was pressed")
			sound.shape.radius = 2
			#change the inputs and radii to make more sense
