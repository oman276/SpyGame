extends CanvasLayer

@onready var background = $TextureRect
@onready var text = $TextureRect/RichTextLabel
@export var fade_duration : float = 0.2

func _ready():
	background.modulate.a = 0
	text.modulate.a = 0

func fade_in():
	background.visible = true
	text.visible = true

	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate:a", 1.0, fade_duration)
	tween.tween_property(text, "modulate:a", 1.0, fade_duration)

func fade_out():
	background.visible = true
	text.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate:a", 0.0, fade_duration)
	tween.tween_property(text, "modulate:a", 0.0, fade_duration)

	await get_tree().create_timer(fade_duration).timeout

	background.visible = false
	text.visible = false