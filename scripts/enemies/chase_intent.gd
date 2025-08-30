class_name ChaseIntent
extends RefCounted

enum ObjectOfInterest {
	PLAYER = 4,
	PLAYER_POSITION = 3,
	OBJECT = 2,
	OBJECT_POSITION = 1,
	NOT_ASSIGNED = 0
}

var object_type : ObjectOfInterest = ObjectOfInterest.NOT_ASSIGNED
var target : Node2D = null
var target_position : Vector2 = Vector2.ZERO

func initialize(_object_type : ObjectOfInterest, _target : Node2D, _target_position : Vector2):
	object_type = _object_type
	target = _target
	target_position = _target_position
	pass

# this must be called manually
func update_intent():
	if target != null:
		target_position = target.position
	pass
