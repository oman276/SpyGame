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

var current_state : EnemyState
@export var initial_state = EnemyState.PATROLLING

@onready var nav_agent = $NavigationAgent2D
@export var nav_manager : NavPointManager

@export var search_target : Node2D
var target_last_known_position : Vector2

@onready var re_path_timer : Timer = $RePathTimer
@export var timer_reset_time : float = 0.2

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
	velocity = direction * base_movement_speed
	if current_state == EnemyState.CHASING:
		velocity *= chase_speed_multiplier
	move_and_slide()

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
