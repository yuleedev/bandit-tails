extends Node2D

var row_size = 2
var items = []

const ITEM_SLOT = preload("res://item_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(row_size):
		items.append([])
		var instance = ITEM_SLOT.instantiate()
		instance.global_position = Vector2(x*115, 0)
		instance.slot_num = x
		add_child(instance)
		items[x] = instance
	items[1] = "je"
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
