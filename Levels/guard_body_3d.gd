extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5
@export var turn_speed = 4.0

func _process(delta):
	var state = get_parent().state
	var target = get_parent().target
	
	#if state == "patrolling": #if there is no target, follow the path
		#target = target #<- placeholder to get rid of error
	#elif state == "returning":
		#target = target
		##reparent($main/Path3D/PathFollow3D)
	#else: 
		#reparent($main)
		#$FaceDirection.look_at(target.global_transform.origin, Vector3.UP)
		#rotate_y(deg_to_rad($FaceDirection.rotation.y * turn_speed))
		#$NavigationAgent3D.set_target_position(target.global_transform.origin)
		#var velocity = ($NavigationAgent3D.get_next_path_position() - transform.origin).normalized() + SPEED * delta
		#move_and_collide(velocity)

## ================ [ GODOT ] ================ ##

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
