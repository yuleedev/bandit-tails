extends Node2D

var row_size = 2
var items = []
var total_value = 0
var temp_value = 0
var player_id : int = 1

const ITEM_SLOT = preload("res://item_slot.tscn")
signal item_dropped(item, position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	for x in range(row_size):
		items.append([])
		var instance = ITEM_SLOT.instantiate()
		instance.global_position = Vector2(x*200, 0)
		instance.slot_num = x
		add_child(instance)
		items[x] = instance
	
func prep_item(res):
	var item = {}
	item['name'] = res.name
	item['inv_icon'] = res.inv_icon
	item['item_path'] = res.item_path
	item['value'] = res.value
	temp_value = res.value
	
	return item
	
func add_item(item):
	for x in range(row_size):
		var slot = items[x] 
		if slot.add_item(item):
			total_value += temp_value
			
			if player_id == GM.p1_id:
				GM.p1_round_value = total_value
			else:
				GM.p2_round_value = total_value
			
			$Label.text = "Total Value: " + str(total_value)
			return true

func drop_item(slot_num: int):
	var slot = items[slot_num]
	if slot.has_item():
		var item = slot.remove_item()
		total_value -= item['value']
		$Label.text = "Total Value: " + str(total_value)
	if player_id == GM.p1_id:
		GM.p1_round_value = total_value
	else:
		GM.p2_round_value = total_value

		emit_signal("item_dropped", items[slot_num], global_position)
		return true
	return false
