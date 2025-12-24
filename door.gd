extends Node3D

var p_near = false
var p_ref = null
var is_open= false
var current_opener_id = -1
@onready var inv = get_node("/root/Main/CanvasLayer/Key")

func _ready():
	pass
	#$Model/Area.body_entered.connect(_on_body_entered)
	#$Model/Area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		body.interactable = self
		p_near = true
		p_ref = body
	
func _on_body_exited(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		if body.interactable == self:
			body.interactable = null
			p_near = false
			p_ref = null

func _process(delta):
	pass

@rpc("any_peer", "call_local")
func open(player_id: int):
	current_opener_id = player_id
	if is_open:
		return
	is_open = true
	$AnimationTree.set("parameters/conditions/unlock", true)

@rpc("any_peer")
func request_door_open(opener_id: int):
	print("requesting open")
	if is_multiplayer_authority() and not is_open:
		open.rpc(opener_id)
