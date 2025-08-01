extends Node3D

var p_near = false
var p_ref = null
var selected_index: int = -1  

@onready var progress = $Body/WeightBar/Sprite3D/SubViewport/ProgressBar
@onready var value_label = $Body/WeightBar/Sprite3D/SubViewport/Label
@onready var mesh_instance: MeshInstance3D = $Body/Mesh
@onready var invM = get_node("/root/Mole/CanvasLayer/Inventory")
@onready var inv = get_node("/root/Main/CanvasLayer/Inventory")

@export var item_res: Array[Item] = []
@export var mesh_options: Array[Mesh] = []
@export var icon_options: Array[Texture2D] = []

var random_seed: int = 0
var is_being_picked_up = false
var current_picker_id = -1
var pickup_progress = 0.0
var pickup_time = 2.0
var is_picked = false

func _ready():
	await get_tree().process_frame
	if is_multiplayer_authority(): 
		_initialize_loot()
		rpc("_sync_loot", selected_index, item_res[selected_index].value, random_seed)
	else:
		visible = false
	progress.value = 0

func _initialize_loot():
	random_seed = randi()
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed
	
	selected_index = rng.randi() % mesh_options.size()
	mesh_instance.mesh = mesh_options[selected_index]
	item_res[selected_index].set_icon(icon_options[selected_index])
	item_res[selected_index].value = rng.randf_range(10, 50)
	visible = true
	rpc("_sync_loot", selected_index, item_res[selected_index].value, random_seed)

@rpc("authority","call_local", "reliable")
func _sync_loot(index: int, value: float, sync_seed: int):
	random_seed = sync_seed
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed
	
	selected_index = index
	if mesh_instance:
		mesh_instance.mesh = mesh_options[selected_index]
	item_res[selected_index].value = value
	visible = true
	
@rpc
func multiplayer_spawned():
	var spawn_data = multiplayer.get_spawn_data()
	global_position = spawn_data.get("position", global_position)
	set_multiplayer_authority(spawn_data.get("authority", 1))

func _on_body_entered(body):
	if body.name == str(GM.p1_id) || body.name == str(GM.p2_id):
		body.interactable = self
		p_near = true
		p_ref = body
		progress.visible = true
		value_label.text = str(item_res[selected_index].value)
		value_label.visible = true

func _on_body_exited(body):
	if body.name == str(GM.p2_id) || body.name == str(GM.p2_id):
		progress.visible = false
		value_label.visible = false
		if body.interactable == self:
			body.interactable = null
			progress.value = 0
			p_near = false
			p_ref = null

func _process(_delta):
	if not visible:
		visible = true
	if mesh_instance and mesh_instance.mesh == null and selected_index >= 0:
		mesh_instance.mesh = mesh_options[selected_index]
	
	if p_near and p_ref and is_being_picked_up:
		if multiplayer.get_unique_id() == current_picker_id:
			progress.value += 50 * _delta
			if progress.value >= 100:
				complete_pickup()

func start_pickup(player_id: int):
	if not is_being_picked_up:
		is_being_picked_up = true
		current_picker_id = player_id
		progress.value = 0
		rpc("update_pickup_state", true, player_id)

func stop_pickup():
	is_being_picked_up = false
	current_picker_id = -1
	progress.value = 0
	rpc("update_pickup_state", false, -1)

@rpc("any_peer", "call_local", "reliable")
func update_pickup_state(picking: bool, picker_id: int):
	is_being_picked_up = picking
	current_picker_id = picker_id
	if not picking:
		progress.value = 0

func complete_pickup():
	if is_picked:
		return
	is_picked = true
	if is_multiplayer_authority():
		if inv.add_item(inv.prep_item(item_res[selected_index])):
			#rpc_id(current_picker_id, "receive_item", selected_index)
			rpc("hide_item")
			queue_free()
	else:
		rpc_id(1, "request_pickup_completion", current_picker_id)

@rpc("any_peer")
func request_pickup_completion(picker_id: int):
	print("requesting pickup")
	if is_multiplayer_authority() and not is_picked:
		is_picked = true
		current_picker_id = picker_id
		#inv.add_item(inv.prep_item(item_res[selected_index]))
		rpc_id(current_picker_id, "receive_item", selected_index)
		rpc("hide_item")
		queue_free()

@rpc("authority")
func receive_item(index: int):
	if inv.add_item(inv.prep_item(item_res[index])):
		rpc_id(current_picker_id, "receive_item", selected_index)
		print("Item added to player", multiplayer.get_unique_id(), "'s inventory")

@rpc("call_local", "reliable")
func hide_item():
	visible = false

func initialize_as_dropped(item: Item):
	if is_multiplayer_authority():
		var index = item_res.find(item)
		if index != -1:
			selected_index = index
			mesh_instance.mesh = mesh_options[index]
			item_res[index] = item
			rpc("_sync_dropped_loot", index, item.value)

@rpc("call_local", "reliable")
func _sync_dropped_loot(index: int, value: float):
	selected_index = index
	mesh_instance.mesh = mesh_options[index]
	item_res[index].value = value
	visible = true
	is_picked = false  
