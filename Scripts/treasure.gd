extends Node3D

var p_near = false
var p_ref = null

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		p_near = true
		p_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		p_near = false
		p_ref = null

func _process(delta):
	if p_near and Input.is_action_just_pressed("interact"):
		pick_up()
		
func pick_up():
	
	queue_free()  
