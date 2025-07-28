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
	
func prep_item(new_item):
	var item = {}
	
	item['name'] = new_item.res.name
	item['inv_icon'] = new_item.res.inv_icon
	item['item_path'] = new_item.res.item_path
	item['value'] = new_item.res.value
	return item
	
func add_item(item):
	for x in range(row_size):
		var slot = items[x]
		
		if slot.add_item(item):
			return true
	return false
