extends Node3D

var p_near = false
var p_ref = null
@onready var progress = $Body/WeightBar/Sprite3D/SubViewport/ProgressBar
@onready var mesh_instance: MeshInstance3D = $Body/Mesh

@export var item_res : Item
@onready var inv = get_node("/root/Main/CanvasLayer/Inventory")
@export var mesh_options: Array[Mesh] = []
@export var icon_options: Array[Texture2D] = []

func _ready():
	var n = randi() % mesh_options.size()
	mesh_instance.mesh = mesh_options[n]
	item_res.set_icon(icon_options[n])
	item_res.randomize_value()
	#$Body/Area.body_entered.connect(_on_body_entered)
	#$Body/Area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		body.interactable = self
		p_near = true
		p_ref = body

func _on_body_exited(body):
	if body.name == "1" || body.name == str(GM.p2_id):
		if body.interactable == self:
			body.interactable = null
			progress.value = 0
			p_near = false
			p_ref = null

func _process(_delta):
	pass
		
func pick_up():
	if progress.value < 100:
		progress.value += 50 * get_process_delta_time()  
	else:
		if inv.add_item(inv.prep_item(item_res)):
			visible = false
			process_mode = Node.PROCESS_MODE_DISABLED
			
