extends CharacterBody2D
class_name Enemy

enum EnemyState {
	IDLE,
	PATROLLING,
	CHASING,
	SEARCHING,
	INVESTIGATING
}

@export var base_movement_speed = 10.0
@export var chase_speed_multiplier = 2.5
var patrol_points : Array[Vector2]
@export var current_patrol_index : int = 0
@export var direction_lerp_speed : float = 5.0

var current_state : EnemyState
@export var initial_state = EnemyState.PATROLLING

@onready var nav_agent = $NavigationAgent2D
@export var nav_manager : NavPointManager

@export var search_target : Node2D
var target_last_known_position : Vector2

@onready var re_path_timer : Timer = $RePathTimer
@export var timer_reset_time : float = 0.2

@onready var sprite : Sprite2D = $CollisionShape2D/WIP_Sprite
@export var sprite_rotation_speed : float = 10.0

var chase_intents : Array[ChaseIntent] = []

# detection polygon
@onready var visual_polygon : Polygon2D = $CollisionShape2D/WIP_Sprite/Detection_Radius/Polygon2D
@onready var collision_polygon : CollisionPolygon2D = $CollisionShape2D/WIP_Sprite/Detection_Radius/CollisionPolygon2D
@export var detection_radius : float = 100.0
@export var detection_angle : float = 90.0
@export var segments : int = 32

func _ready():
	current_state = initial_state

	match initial_state:
		EnemyState.PATROLLING:
			if nav_manager != null:
				patrol_points = nav_manager.get_points()
				if patrol_points.size() > 0:
					var target = patrol_points[current_patrol_index]
					nav_agent.set_target_position(target)
		EnemyState.CHASING:
			if search_target != null:
				nav_agent.set_target_position(search_target.global_position)

	re_path_timer.start(timer_reset_time)

func change_state(new_state : EnemyState):
	if new_state == current_state:
		return
	print("Changing state from ", str(current_state), " to ", str(new_state))
	current_state = new_state
	match new_state:
		EnemyState.PATROLLING:
			if patrol_points.size() > 0:
				var target = patrol_points[current_patrol_index]
				nav_agent.set_target_position(target)
		EnemyState.CHASING:
			if search_target != null:
				nav_agent.set_target_position(search_target.global_position)
		EnemyState.SEARCHING:
			if search_target != null:
				target_last_known_position = search_target.global_position
				nav_agent.set_target_position(target_last_known_position)
		EnemyState.IDLE:
			# do nothing, we don't need to set a position
			pass

func _physics_process(_delta: float) -> void:
	if current_state == EnemyState.IDLE:
		return
	if nav_agent.is_navigation_finished():
		make_path()
		return
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = lerp(velocity, direction * base_movement_speed, direction_lerp_speed * _delta)
	if current_state == EnemyState.CHASING:
		velocity *= chase_speed_multiplier
	move_and_slide()
	sprite.rotation = lerp_angle(sprite.rotation, velocity.angle(), sprite_rotation_speed * _delta)
	_draw_detection_polygon()

func make_path():
	match current_state:
		EnemyState.PATROLLING:
			if patrol_points.size() == 0:
				return
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			print("making new path on index ", current_patrol_index)
			var target = patrol_points[current_patrol_index]
			nav_agent.set_target_position(target)
		EnemyState.CHASING, EnemyState.SEARCHING:
			# when chasing, we'd want to update the path more frequently: use timer?
			if search_target != null:
				nav_agent.set_target_position(search_target.global_position)
		EnemyState.IDLE:
			# do nothing, we don't need to set a position
			pass

func _on_re_path_timer_timeout():
	if current_state == EnemyState.CHASING or current_state == EnemyState.SEARCHING:
		# print("Recalculating path...")
		make_path()

func is_object_of_interest(node: Node2D) -> bool:
	var is_interest = false
	if node is SpyPlayer:
		is_interest = true
	return is_interest

func _on_detection_radius_body_entered(body:Node2D):
	print(body.name, " entered")

func _on_detection_radius_body_exited(body:Node2D):
	print(body.name, " exited.")

func _draw_detection_polygon():
	var points = PackedVector2Array()
	var half_angle = deg_to_rad(detection_angle) / 2.0
	var space_state = get_world_2d().direct_space_state

	points.append(Vector2.ZERO)
	for i in range(segments + 1):
		var angle : float = -half_angle + (i / float(segments)) * (2.0 * half_angle)
		var point = Vector2(cos(angle), sin(angle)) * detection_radius
		var ray_point = point + global_position
		# points.append(point)
		var query = PhysicsRayQueryParameters2D.create(global_position, ray_point)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result.size() > 0:
			points.append(to_local(result.position))
			# DebugDraw3D.draw_line(Vector3(global_position.x, global_position.y, 5), Vector3(result.position.x, result.position.y, 5), Color.RED, 0.2)
		else:
			points.append(point)
			# DebugDraw3D.draw_line(Vector3(global_position.x, global_position.y, 5), Vector3(point.x, point.y, 5), Color.RED, 0.2)

	# only update if necessary
	if visual_polygon.polygon != points:
		visual_polygon.polygon = points
	if collision_polygon.polygon != points:
		collision_polygon.polygon = points
