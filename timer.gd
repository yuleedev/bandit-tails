extends Label

var total_time := 180.0  # 3 minutes in seconds

func _process(delta: float) -> void:
	if total_time > 0:
		total_time -= delta
		var minutes = int(total_time) / 60
		var seconds = int(total_time) % 60
		text = "%02d:%02d" % [minutes, seconds]
	else:
		text = "00:00"
		# Optionally: call game_over() or emit_signal("time_up")
