extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vision_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("guard has seen " + body.name) 

func _on_vision_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("guard has unseen " + body.name)

func _on_listening_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("guard has heard " + area.name) 

func _on_listening_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("guard has unheard " + area.name) 
