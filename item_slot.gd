extends Node

@onready var item_icon = $ItemIcon
@onready var value_label = $Value

var slot_num = 0
var item : Dictionary
var item_value = 0
func add_item(new_item):
	if item == {}:
		item = new_item
		item_value = item['value'] 
		item_icon.texture = item['inv_icon']
		refresh_label()
		$ItemIcon.visible = true
		return true
	return false

func refresh_label():
	value_label.text = str(item_value)
