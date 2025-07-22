extends Node

## ================ [ CONST ] ================ ##

const NONZERO: float = 0.01

## ================ [ VECTOR ] ================ ##

func to_3d(vec: Vector2) -> Vector3:
	return Vector3(vec.x, 0, vec.y)
