extends CharacterBody3D

## ================ [ FIELDS ] ================ ##

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera
@onready var light: SpotLight3D = $Pivot/Camera/Light
@onready var sound: CollisionShape3D = $SoundArea3D/CollisionShape3D

@export var MOVE_SPEED: float = 5

var input_dir: Vector2
var move_dir: Vector3
var interactable: Node = null

var mouse_motion: Vector2

## ================ [ METHODS ] ================ ##

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
	
	velocity = move_dir * MOVE_SPEED
	
	#object pick up
	if interactable:
		if interactable.is_in_group("loot") and Input.is_action_just_pressed("interact"):
			interactable.pick_up()
		elif interactable.is_in_group("door") and Input.is_action_just_pressed("interact"):
			interactable.open()


## ================ [ GODOT ] ================ ##

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.screen_relative

func _process(delta: float) -> void:
	_rotate_camera()
	_apply_movement()

func _physics_process(_delta: float) -> void:
	move_and_slide()

##picking up stuff
func _on_body_entered(body):
	if body.is_in_group("loot") or body.is_in_group("door"):
		interactable = body

func _on_body_exited(body):
	if interactable == body:
		interactable = null

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
