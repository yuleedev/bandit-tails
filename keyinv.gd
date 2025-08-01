extends Node2D



func add_item():
	print("" + str(GM.keys))
	#if GM.keys == 0:
		#$KeyIcon.visible = false
	#elif GM.keys > 0:
		#$KeyIcon.visible = true
	$Label.text = str(GM.keys)
