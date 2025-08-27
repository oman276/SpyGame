extends Node
class_name NavPointManager

func get_points() -> Array[Vector2]:
	var children = get_children()
	children.sort_custom(func(a, b):
		assert(a.name.is_valid_int() and b.name.is_valid_int())
		return int(a.name) < int(b.name)
	)
	var points : Array[Vector2] = []
	for child in children:
		points.append(child.position)
	return points
