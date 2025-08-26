extends Node2D
class_name Pickup

var base_scale : Vector2 = Vector2(1, 1)
@export var held_scale : Vector2 = Vector2(1, 1)
@onready var rigid_body : RigidBody2D = $RigidBody2D

func click_action(player_pos : Vector2, mouse_pos : Vector2):
	print("click action pressed")

func pick_up():
	print(name, "picked up")
	# Disable physics when picked up
	if rigid_body:
		rigid_body.freeze = true
		rigid_body.set_collision_layer_value(1, false)  # Disable collision layer 1
		rigid_body.set_collision_layer_value(2, false)  # Disable collision layer 2
		rigid_body.set_collision_mask_value(1, false)   # Disable collision mask 1
		rigid_body.set_collision_mask_value(2, false)   # Disable collision mask 2

func drop():
	print(name, "dropped")
	# Re-enable physics when dropped
	if rigid_body:
		rigid_body.freeze = false
		rigid_body.set_collision_layer_value(1, true)   # Re-enable collision layer 1
		rigid_body.set_collision_layer_value(2, true)   # Re-enable collision layer 2
		rigid_body.set_collision_mask_value(1, true)    # Re-enable collision mask 1
		rigid_body.set_collision_mask_value(2, true)    # Re-enable collision mask 2

func next_to_pick_up(is_next : bool):
	if is_next:
		print(name, "This is next to pick up")
	else:
		print(name, "This is no longer next to pick up")