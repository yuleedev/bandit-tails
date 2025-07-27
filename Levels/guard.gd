extends CharacterBody3D

@export var speed = 200
@export var detection_range = 200

@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight
@onready var player = null

var is_chasing = false

func _physics_process(delta):
	if player != null:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		# Patrol or other behavior
		pass

	if detect_player():
		if !is_chasing:
			is_chasing = true
			# Transition to chasing state
			print("Player Detected!")
	else:
		if is_chasing:
			is_chasing = false
			# Transition to patrol or other state
			print("Player Lost")
			
func detect_player():
	if ray_left.is_colliding():
		if ray_left.get_collider().name == "Player":
			player = ray_left.get_collider()
			return true
	if ray_right.is_colliding():
		 if ray_right.get_collider().name == "Player":
			 player = ray_right.get_collider()
			 return true
	return false
