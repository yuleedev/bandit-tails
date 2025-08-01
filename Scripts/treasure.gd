extends Node3D

var p_near = false
var p_ref = null
var selected_index: int = -1  

@onready var progress = $Body/WeightBar/Sprite3D/SubViewport/ProgressBar
@onready var value_label = $Body/WeightBar/Sprite3D/SubViewport/Label
@onready var mesh_instance: MeshInstance3D = $Body/Mesh
@onready var inv = get_node("/root/Main/CanvasLayer/Inventory")

@export var item_res: Array[Item] = []
@export var mesh_options: Array[Mesh] = []
@export var icon_options: Array[Texture2D] = []

func _ready():
	if is_multiplayer_authority():  # Only server initializes
		selected_index = randi() % mesh_options.size()
		var value = randf_range(10, 50)
		
		mesh_instance.mesh = mesh_options[selected_index]
		item_res[selected_index].set_icon(icon_options[selected_index])
		item_res[selected_index].value = value
		
		rpc("_sync_loot", selected_index, value)


func _enter_tree():
	set_multiplayer_authority(1)
	print("Loot entered tree for: ", multiplayer.get_unique_id())
	print("Is authority: ", is_multiplayer_authority())

func _initialize_loot():
	selected_index = randi() % mesh_options.size()
	mesh_instance.mesh = mesh_options[selected_index]
	item_res[selected_index].set_icon(icon_options[selected_index])
	item_res[selected_index].value = RandomNumberGenerator.new().randf_range(10, 50)

@rpc("authority","call_local", "reliable")
func _sync_loot(index: int, value: float):
	selected_index = index
	mesh_instance.mesh = mesh_options[selected_index]
	item_res[selected_index].value = value
	visible = true
@rpc
func multiplayer_spawned():
	print("Loot spawned for peer: ", multiplayer.get_unique_id())
	print("Authority: ", get_multiplayer_authority())
	var spawn_data = multiplayer.get_spawn_data()
	global_position = spawn_data.get("position", global_position)
	set_multiplayer_authority(spawn_data.get("authority", 1))


func _on_body_entered(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		body.interactable = self
		p_near = true
		p_ref = body
		progress.visible = true
		value_label.text = str(item_res[selected_index].value)
		value_label.visible = true

func _on_body_exited(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		progress.visible = false
		value_label.visible = false
		if body.interactable == self:
			body.interactable = null
			progress.value = 0
			p_near = false
			p_ref = null

func _process(_delta):
	if visible != is_visible_in_tree():
		print("Visibility mismatch! Visible: %s, In tree: %s" % [visible, is_visible_in_tree()])
	pass

@rpc("any_peer")
func request_pick_up(peer_id: int):
	print("request_pick_up called by:", peer_id)
	print("i want to pick")
	if not is_multiplayer_authority():
		print("im a mere peasant")
		return 
	if selected_index >= 0 and selected_index < item_res.size():
		print("i got the authority")
		rpc_id(peer_id, "receive_item", selected_index)
		rpc("hide_item")
		process_mode = Node.PROCESS_MODE_DISABLED

@rpc("authority")
func receive_item(index: int):
	if inv.add_item(inv.prep_item(item_res[index])):
		print("Item added to inventory")

@rpc("authority")
func hide_item():
	visible = false


#func pick_up():
	#if progress.value < 100:
		#progress.value += 50 * get_process_delta_time()  
	#else:
		#if selected_index >= 0 and selected_index < item_res.size():
			#if inv.add_item(inv.prep_item(item_res[selected_index])):
				#visible = false
				#process_mode = Node.PROCESS_MODE_DISABLED
