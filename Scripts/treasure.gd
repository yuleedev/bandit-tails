extends Node3D

var p_near = false
var p_ref = null
@onready var progress = $Body/Gui/Sprite3D/SubViewport/ProgressBar

func _ready():
	pass
	#$Body/Area.body_entered.connect(_on_body_entered)
	#$Body/Area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		body.interactable = self
		p_near = true
		p_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		if body.interactable == self:
			body.interactable = null
			progress.value = 0
			p_near = false
			p_ref = null

func _process(delta):
	pass
		
func pick_up():
	if progress.value < 100:
		progress.value += 50 * get_process_delta_time()  
	else:
		queue_free()
