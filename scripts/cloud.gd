@tool
extends Node2D
# A simple flat cloud: a rounded base plus three puffs.

@export var cloud_width: float = 160.0:
	set(value):
		cloud_width = value
		queue_redraw()

@export var cloud_color: Color = Color.WHITE:
	set(value):
		cloud_color = value
		queue_redraw()


func _draw() -> void:
	var w := cloud_width
	var h := w * 0.25
	# Rounded base (a "pill" shape)
	draw_rect(Rect2(-w / 2 + h / 2, -h, w - h, h), cloud_color)
	draw_circle(Vector2(-w / 2 + h / 2, -h / 2), h / 2, cloud_color)
	draw_circle(Vector2(w / 2 - h / 2, -h / 2), h / 2, cloud_color)
	# Puffs on top
	draw_circle(Vector2(-w * 0.2, -h), h * 0.8, cloud_color)
	draw_circle(Vector2(w * 0.05, -h * 1.3), h * 1.1, cloud_color)
	draw_circle(Vector2(w * 0.28, -h), h * 0.7, cloud_color)
