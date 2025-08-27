extends Control

@onready var mouse_sprite : Sprite2D

func _ready():
	mouse_sprite = $MouseSprite

func _process(_delta):
	position = get_global_mouse_position()
