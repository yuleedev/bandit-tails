extends Node3D

## ================ [ FIELDS ] ================ ##
var target: CharacterBody3D

## ================ [ GODOT ] ================ ##
func _ready() -> void:
	pass

func _on_vision_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("guard has seen " + body.name)
		target = body 
		target.global_position = Vector3(0, 1, 0)

func _on_vision_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("guard has unseen " + body.name)
		target = null 

func _on_listening_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("guard has heard " + area.name) 
		target = area.get_parent()
		target.global_position = Vector3(0, 1, 0)

func _on_listening_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("guard has unheard " + area.name)
		target = null  
