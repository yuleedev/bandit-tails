extends Node

@onready var item_icon = $Item_Icon
@onready var value_label = $Value

var slot_num = 0
var item : Dictionary
var item_value = 0

func add_item(new_item):
	if item == {}:
		item = new_item
		item_icon.texture = item['inv_icon']
		refresh_label()
		return true
	return false

func refresh_label():
	value_label.text = str(item_value)
