@tool
extends StaticBody2D
# @tool makes this script also run inside the editor,
# so changing Size in the Inspector resizes the platform immediately.
# The node's position is the platform's TOP-LEFT corner, which makes
# level layout easy: position.y = the height of the walkable surface.

@export var size: Vector2 = Vector2(400, 200):
	set(value):
		size = value
		_update_shape()

@export var color: Color = Color(0.9, 0.1, 0.1):
	set(value):
		color = value
		_update_shape()


func _ready() -> void:
	_update_shape()


func _update_shape() -> void:
	# Setters can run before the child nodes exist; wait until ready.
	if not is_node_ready():
		return
	# A NEW shape per platform, so resizing one never resizes the others.
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = size / 2.0   # shapes are centered, so shift to top-left origin
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(size.x, 0), size, Vector2(0, size.y)
	])
	$Polygon2D.color = color
