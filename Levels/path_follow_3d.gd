extends PathFollow3D

@export var speed: float = 3.0  # Units per second

func _process(delta):
	# Move along the path
	progress += speed * delta
