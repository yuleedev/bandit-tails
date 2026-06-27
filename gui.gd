extends Node3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var sub_viewport: SubViewport = $Sprite3D/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Assign the viewport texture at runtime. Serializing a ViewportTexture's
	# viewport_path in the scene breaks the web export with
	# "Path to node is invalid: 'Sprite3D/SubViewport'".
	sprite.texture = sub_viewport.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
