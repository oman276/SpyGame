extends Node2D

enum GameState {
	DEFAULT,
	PAUSED
}

enum Levels {
	NONE,
	MENU,
	CREDITS,
	TEST_SCENE
}

var level_str_dict : Dictionary = {
	Levels.NONE : "",
	Levels.MENU : "res://scenes/levels/menu.tscn",
	Levels.CREDITS : "res://scenes/levels/credits.tscn",
	Levels.TEST_SCENE : "res://scenes/levels/test_scene.tscn"
}

var loading_canvas : CanvasLayer = null
var loading_canvas_path : String = "res://scenes/systems/loading_canvas.tscn"
var loading_time : float = 0.1

@export var initial_level : Levels = Levels.TEST_SCENE
var current_global_state : GameState = GameState.DEFAULT
var current_level : Levels = Levels.NONE
var current_level_node : Node2D = null

# Mouse Reticle
var mouse_reticle : Control
var mouse_reticle_tscn : PackedScene

func _ready():
	var temp = load(loading_canvas_path)
	loading_canvas = temp.instantiate()
	add_child(loading_canvas)

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_reticle_tscn = load("res://scenes/mouse_reticle.tscn")
	mouse_reticle = mouse_reticle_tscn.instantiate()
	add_child(mouse_reticle)
	
	load_level(initial_level)


func load_level(level: Levels) -> void:
	if level == current_level:
		return
	_force_load_level(level)

func reload_level() -> void:
	_force_load_level(current_level)

func _force_load_level(level: Levels):
	current_level = level
	loading_canvas.fade_in()
	await get_tree().create_timer(loading_time).timeout

	if current_level_node:
		remove_child(current_level_node)
		current_level_node.queue_free()
		current_level_node = null

	var scene_str = level_str_dict[level]
	if scene_str != "":
		var scene = load(scene_str)
		current_level_node = scene.instantiate()
		add_child(current_level_node)
	loading_canvas.fade_out()
