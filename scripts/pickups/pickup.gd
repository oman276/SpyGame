extends Node2D
class_name Pickup

var base_scale : Vector2 = Vector2(1, 1)
@export var held_scale : Vector2 = Vector2(1, 1)

func click_action(player_pos : Vector2, mouse_pos : Vector2):
	print("click action pressed")

func pick_up():
	print("object picked up")
	pass

func drop():
	print("object dropped")
	pass

func next_to_pick_up(is_next : bool):
	if is_next:
		print("This is next to pick up")
	else:
		print("This is no longer next to pick up")