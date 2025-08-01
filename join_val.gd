extends Label

func _process(delta):
	if multiplayer.get_unique_id() == GM.p1_id:
		text = str(int(GM.p2_round_value))
