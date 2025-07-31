extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_pressed() -> void:
	if $Start.visible:
		$Start.visible = false
		$Mole.visible = true
		$Prev.visible = true
	elif $Mole.visible:
		$Mole.visible = false
		$Raccoon.visible = true
		$Next.visible = false
		if multiplayer.get_unique_id() == GM.p1_id:
			$SelectB.visible = true

func _on_prev_pressed() -> void:
	if $Mole.visible:
		$Mole.visible = false
		$Start.visible = true
		$Prev.visible = false
		#$SelectB.visible = false
	elif $Raccoon.visible:
		$Raccoon.visible = false
		$Mole.visible = true
		$Next.visible = true



func _on_select_b_pressed() -> void:
	if $Mole.visible:
		#set host to mole
		#set p1 to raccoon
		pass
	else:
		#set host to raccoon
		#set p1 to mole
		pass
	GM.start_game()
