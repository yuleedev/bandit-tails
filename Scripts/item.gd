extends Resource
class_name Item

@export var name: String
@export_enum("Vase", "Clock") var type: String
@export var inv_icon: Texture2D
@export var value: int
@export var item_path: String



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
