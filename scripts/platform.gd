@tool
extends StaticBody2D
# Draws a stone-brick platform with a grass top, entirely in code.
# The node's position is the platform's TOP-LEFT corner.

@export var size: Vector2 = Vector2(400, 200):
	set(value):
		size = value
		_update_shape()

@export var color: Color = Color("4a5568"):        # stone color
	set(value):
		color = value
		queue_redraw()

@export var grass_color: Color = Color("5cb85c"):
	set(value):
		grass_color = value
		queue_redraw()

@export var has_grass: bool = true:
	set(value):
		has_grass = value
		queue_redraw()

const BRICK_W := 80.0
const BRICK_H := 40.0
const GRASS_H := 14.0


func _ready() -> void:
	_update_shape()


func _update_shape() -> void:
	queue_redraw()
	# Setters can run before the child nodes exist; wait until ready.
	if not is_node_ready():
		return
	# A NEW shape per platform, so resizing one never resizes the others.
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = size / 2.0


func _draw() -> void:
	var mortar := color.darkened(0.35)

	# Stone body
	draw_rect(Rect2(Vector2.ZERO, size), color)

	# Brick pattern: every second row is shifted half a brick
	var y := 0.0
	var row := 0
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), mortar, 3.0)
		var x := BRICK_W * 0.5 if row % 2 == 1 else BRICK_W
		while x < size.x:
			draw_line(Vector2(x, y), Vector2(x, minf(y + BRICK_H, size.y)), mortar, 3.0)
			x += BRICK_W
		y += BRICK_H
		row += 1

	# Outline
	draw_rect(Rect2(Vector2.ZERO, size), mortar, false, 4.0)

	if has_grass:
		draw_rect(Rect2(0, 0, size.x, GRASS_H), grass_color)
		draw_rect(Rect2(0, GRASS_H - 4, size.x, 4), grass_color.darkened(0.3))
		# Small grass blades; sin() gives varied but stable heights
		var bx := 6.0
		while bx < size.x - 6.0:
			var h := 5.0 + 4.0 * absf(sin(bx * 12.9898))
			draw_colored_polygon(PackedVector2Array([
				Vector2(bx - 4, 0), Vector2(bx + 4, 0), Vector2(bx, -h)
			]), grass_color)
			bx += 14.0
