extends CharacterBody3D
class_name Player

## ================ [ NODES ] ================ ##

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera
@onready var light: SpotLight3D = $Pivot/Camera/Light

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var area: Area3D = $SoundArea
@onready var sound: CollisionShape3D = $SoundArea/Collider

## ================ [ FIELDS ] ================ ##
@export var can_move = true

@export_group("Movement")
@export var MOVE_SPEED: float = 5
@export var ACCELERATION: float = 30

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

func _punishment() -> void:
	#print("you got caught!")
	velocity = Vector3.ZERO
	can_move = false
	global_position = Vector3(0, 1, 0)
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	can_move = true
	#print("you're free!")
	

func _update_timers(delta: float) -> void:
	if cd > 0:
		cd -= delta

func _rotate_camera() -> void:
	pivot.rotation.y -= mouse_motion.x * GM.options.MOUSE_SENSITIVITY
	camera.rotation.x -= mouse_motion.y * GM.options.MOUSE_SENSITIVITY
	camera.rotation.x = clamp(camera.rotation.x, -PI/2 + Math.NONZERO, PI/3)
	
	mouse_motion = Vector2.ZERO

func _apply_movement(delta) -> void:
	if can_move:
		input_dir = Input.get_vector("left", "right", "up", "down")
		move_dir = (
			pivot.transform.basis * Math.to_3d(input_dir)
		).normalized()
		
		velocity = velocity.move_toward(move_dir * MOVE_SPEED, ACCELERATION * delta)

func _manage_interactable() -> void:
	if interactable:
		print("we")
		if interactable.is_in_group("loot") and Input.is_action_pressed("interact"):
			interactable.pick_up()
			print("we")
		elif interactable.is_in_group("door") and Input.is_action_just_pressed("interact"):
			interactable.open()
			print("de")
			
	

func _manage_skill() -> void:
	if Input.is_action_just_pressed("skill") and cd <= 0:
		use_skill()
		cd = COOLDOWN

## ================ [ GODOT ] ================ ##

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_entered.connect(_on_body_exited)

func _process(delta: float) -> void:
	_update_timers(delta)
	
	_rotate_camera()
	_apply_movement(delta)
	
	_manage_interactable()
	_manage_skill()

func _physics_process(_delta: float) -> void:
	# print(get_slide_collision(0))
	move_and_slide()

func _on_body_entered(body):
	print(body)
	if body.is_in_group("loot") or body.is_in_group("door"):
		print("Body is interactable")
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
