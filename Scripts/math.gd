extends Node

## ================ [ VECTOR ] ================ ##

func to_3d(vec: Vector2) -> Vector3:
	return Vector3(vec.x, 0, vec.y)
