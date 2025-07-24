extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vision_area_3d_body_entered(body: Node3D) -> void:
	print("guard has seen " + body.name) 
	pass # Replace with function body.


func _on_vision_area_3d_body_exited(body: Node3D) -> void:
	print("guard has unseen " + body.name)
	pass # Replace with function body.


func _on_listening_area_3d_body_entered(body: Node3D) -> void:
	print("guard has heard " + body.name)
	pass # Replace with function body.


func _on_listening_area_3d_body_exited(body: Node3D) -> void:
	print("guard has unheard " + body.name)
	pass # Replace with function body.
