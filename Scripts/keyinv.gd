extends Node2D

var keys = 0

func add_item():
	print("p1" + str(multiplayer.get_unique_id()) + str(GM.p1_keys))
	print("p2" + str(multiplayer.get_unique_id()) + str(GM.p2_keys))
	#if GM.keys == 0:
		#$KeyIcon.visible = false
	#elif GM.keys > 0:
		#$KeyIcon.visible = true
	if multiplayer.get_unique_id() == GM.p1_id:
		$Label.text = str(GM.p1_keys)
		print("p1 show" + str(multiplayer.get_unique_id()) + str(GM.p1_keys))
	else:
		$Label.text = str(GM.p2_keys)
		print("p2 show" + str(multiplayer.get_unique_id()) + str(GM.p2_keys))
