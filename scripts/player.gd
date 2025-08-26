extends CharacterBody2D
class_name SpyPlayer

@export_category("Movement Properties")

@export_group("Basic Movement")
@export var speed : float = 300
@export var acceleration : float = 25
@export var friction : float = 10

@export_group("Sprinting")
@export var sprint_speed_multiplier : float = 1.5
@export var sprint_acceleration_multiplier : float = 1.5
@export var sprint_friction_multiplier : float = 0.5

@export_group("Dodging")
enum PlayerMoveState {
	FREE,
	DODGING
}
var _move_state : PlayerMoveState = PlayerMoveState.FREE
var _dodge_vector : Vector2 = Vector2(1, 0)
@export var dodge_duration : float = 0.35
@export var dodge_duration_sprinting : float = 0.5
@export var dodge_friction : float = 30.0
@export var dodge_friction_sprinting : float = 4000.0
@export var dodge_speed_multiplier : float = 2.0
@export var dodge_speed_sprint_multiplier : float = 6
@onready var dodge_timer : Timer = $DodgeTimer

@onready var HoldRotator : Node2D = $HoldRotator
@onready var HoldPoint : Node2D = $HoldRotator/HoldPoint
var held_object : Pickup = null
var next_held_object : Pickup = null
var held_object_list : Array = []

func _process(_delta):
	HoldRotator.look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("dodge"):
		_dodge()
	if Input.is_action_just_pressed("pick_up"):
		_pick_up()
	if Input.is_action_just_pressed("drop"):
		_drop()

func _physics_process(delta):
	match _move_state:
		# Player-Controlled Movement
		PlayerMoveState.FREE:
			var speed_values = _get_speed_values()
			var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			if input_direction != Vector2.ZERO:
				velocity = velocity.move_toward(input_direction * speed_values["speed"], speed_values["acceleration"] * delta)
			else:
				velocity = velocity.move_toward(Vector2(0, 0), speed_values["friction"] * delta)

		# Dodging
		PlayerMoveState.DODGING:
			velocity = velocity.move_toward(Vector2.ZERO, dodge_friction * delta)

	move_and_slide()

func _get_speed_values() -> Dictionary:
	var _i_speed = speed * (sprint_speed_multiplier if is_sprinting() else 1.0)
	var _i_acceleration = acceleration * (sprint_acceleration_multiplier if is_sprinting() else 1.0)
	var _i_friction = friction * (sprint_friction_multiplier if is_sprinting() else 1.0)
	return {
		"speed" : _i_speed, 
		"acceleration" : _i_acceleration, 
		"friction" : _i_friction
	}

func _on_dodge_timer_timeout():
	_move_state = PlayerMoveState.FREE

func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint")

func _dodge():
	_move_state = PlayerMoveState.DODGING
	_dodge_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = _dodge_vector * speed * (dodge_speed_sprint_multiplier if is_sprinting() else dodge_speed_multiplier)
	dodge_timer.stop()
	dodge_timer.start(dodge_duration_sprinting if is_sprinting() else dodge_duration)

func _pick_up():
	var item = _pop_pickup_from_list()
	if item != null:
		if held_object != null:
			_drop()
			await get_tree().process_frame
		held_object = item
		held_object.pick_up()

		if held_object.get_parent() != null:
			get_parent().remove_child(held_object)
		HoldPoint.add_child(held_object)
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0
		print("picked up item ", item.name)

func _drop() -> Node2D:
	if held_object != null:
		HoldPoint.remove_child(held_object)
		get_parent().add_child(held_object)
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0
		print("dropped item ", held_object.name)
		held_object.drop()
		var original_held = held_object
		held_object = null
		return original_held
	return null


func _add_pickup_to_list(pickup: Pickup):
	held_object_list.append(pickup)

func _pop_pickup_from_list() -> Pickup:
	if held_object_list.size() > 0:
		return held_object_list.pop_front()
	return null

func _peek_pickup_from_list() -> Pickup:
	if held_object_list.size() > 0:
		return held_object_list[0]
	return null

func _remove_pickup_from_list(pickup: Pickup):
	held_object_list.erase(pickup)

func _update_next_pickup():
	var item = _peek_pickup_from_list()
	if item != null and item != next_held_object:
		if next_held_object != null:
			next_held_object.next_to_pick_up(false)
		next_held_object = item
		next_held_object.next_to_pick_up(true)
	elif item == null and next_held_object != null:
		next_held_object.next_to_pick_up(false)
		next_held_object = null

func _on_item_detection_zone_body_entered(body:Node2D):
	var pickup = body.get_parent()
	if pickup is Pickup:
		print(pickup.name, "has entered zone")
		_add_pickup_to_list(pickup)
		_update_next_pickup()

func _on_item_detection_zone_body_exited(body:Node2D):
	var pickup = body.get_parent()
	if pickup is Pickup:
		print(pickup.name, "has exited zone")
		_remove_pickup_from_list(pickup)
		_update_next_pickup()
