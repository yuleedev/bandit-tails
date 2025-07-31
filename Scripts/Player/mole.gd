extends Player
class_name Mole

## ================ [ FIELDS ] ================ ##

@export var DIG_MOVE_SPEED: float = 10
@export var DIG_DEPTH: float = 1.5
@export var DIG_DURATION: float = 10
@export var is_digging = false
var dig_timer: Timer


## ================ [ PLAYER ] ================ ##

func _ready():
	super._ready()
	dig_timer = Timer.new()
	dig_timer.one_shot = true
	dig_timer.wait_time = DIG_DURATION
	dig_timer.timeout.connect(stop_dig)
	add_child(dig_timer)

func use_skill() -> void:
	if is_digging:
		stop_dig()
	else:
		start_dig()

func start_dig() -> void:
	if is_digging:
		return
	is_digging = true

	if is_in_group("player"):
		remove_from_group("player")
	
	if sound == null:
		push_error("Sound node is null")
	else:
		sound.disabled = true

	if camera == null:
		push_error("Camera node is null")
		return
	
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:x", -60.0, 1)
	tween.parallel().tween_property(camera, "position:y", camera.position.y - DIG_DEPTH, 0.3)
	tween.tween_property(camera, "rotation_degrees:x", 0.0, 0.3)

	dig_timer.start()
	
func stop_dig():
	if not is_digging:
		return
	is_digging = false

	if not is_in_group("player"):
		add_to_group("player")
		
	sound.disabled = false
	
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:x", 60.0, 1)
	tween.parallel().tween_property(camera, "position:y", camera.position.y + DIG_DEPTH, 0.3)
	tween.tween_property(camera, "rotation_degrees:x", 0.0, 0.3)
