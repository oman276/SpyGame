extends CharacterBody2D
class_name Enemy

enum EnemyState {
	IDLE,
	PATROLLING,
	CHASING,
	SEARCHING,
}

@export var base_movement_speed = 10.0
@export var chase_speed_multiplier = 2.5
@export var patrol_points : Array[Vector2]
@export var current_patrol_index : int = 0

var current_state : EnemyState
@export var initial_state = EnemyState.PATROLLING

@onready var nav_agent = $NavigationAgent2D

func _ready():
	current_state = initial_state
	var target = patrol_points[current_patrol_index]
	nav_agent.set_target_position(target)
	
func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		print("Reached target position")
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
		EnemyState.CHASING:
			# when chasing, we'd want to update the path more frequently: use timer?
			print("WIP")
			pass
		EnemyState.SEARCHING:
			print("WIP")
			pass
		EnemyState.IDLE:
			print("WIP")
			pass
