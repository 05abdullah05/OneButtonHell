@tool
extends Area2D
# Draws a shaded spike (light left side, dark right side) in code.

@export var spike_color: Color = Color("e53e3e"):
	set(value):
		spike_color = value
		queue_redraw()


func _ready() -> void:
	queue_redraw()
	# @tool scripts also run in the editor; only detect the player in the game.
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# The floor also touches the spike, so only react to the player.
	if body is Player:
		body.die()


func _draw() -> void:
	var left := PackedVector2Array([Vector2(-20, 0), Vector2(0, -40), Vector2(0, 0)])
	var right := PackedVector2Array([Vector2(0, 0), Vector2(0, -40), Vector2(20, 0)])
	draw_colored_polygon(left, spike_color.lightened(0.25))
	draw_colored_polygon(right, spike_color.darkened(0.2))
	draw_polyline(PackedVector2Array([
		Vector2(-20, 0), Vector2(0, -40), Vector2(20, 0), Vector2(-20, 0)
	]), spike_color.darkened(0.6), 2.0)
