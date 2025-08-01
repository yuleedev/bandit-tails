extends Node3D

var p_near = false
var p_ref = null
@onready var inv = get_node("/root/Main/CanvasLayer/Key")
var current_picker_id = -1

func _ready():
	visible = true
	pass

@rpc
func multiplayer_spawned():
	var spawn_data = multiplayer.get_spawn_data()
	global_position = spawn_data.get("position", global_position)
	set_multiplayer_authority(spawn_data.get("authority", 1))
	visible = true

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


@rpc("any_peer")
func pick_up(player_id: int):
	current_picker_id = player_id
	if is_multiplayer_authority():
		GM.p1_keys += 1
		inv.add_item()
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		queue_free() 
	else:
		GM.p2_keys += 1
		inv.add_item()
		rpc_id(1, "request_pickup_completion", current_picker_id)

@rpc("any_peer")
func request_pickup_completion(picker_id: int):
	if is_multiplayer_authority():
		current_picker_id = picker_id
		visible = false
		queue_free()
