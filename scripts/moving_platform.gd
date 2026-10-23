@tool
extends AnimatableBody2D
# A wooden plank that moves between its start position and start + travel.
# Position = top-left corner, like Platform. It draws a dotted track of its
# whole path, so the player can see where it goes before getting there.
# AnimatableBody2D = a physics body moved by code that carries whatever stands on it.

@export var size: Vector2 = Vector2(160, 24):
	set(value):
		size = value
		_update_shape()

@export var travel: Vector2 = Vector2(0, -120):   # how far it moves from the start
	set(value):
		travel = value
		queue_redraw()

@export var duration: float = 1.2   # seconds to move one way
@export var phase: float = 0.0      # 0..1: where in its cycle it starts

const WOOD := Color("b7794a")
const WOOD_DARK := Color("7b4a2a")
const TRACK := Color(1, 1, 1, 0.45)

var start: Vector2
var time: float = 0.0


func _ready() -> void:
	start = position
	time = phase * 2.0 * duration
	_update_shape()
	if not Engine.is_editor_hint():
		_move()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta
	_move()


func _move() -> void:
	# Smooth back-and-forth: k goes 0 -> 1 -> 0, slowing down at both ends
	# (like a pendulum), so the turning points are easy to read.
	var k := (1.0 - cos(time / duration * PI)) * 0.5
	position = start + travel * k
	queue_redraw()


func _update_shape() -> void:
	queue_redraw()
	if not is_node_ready():
		return
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = size / 2.0


func _draw() -> void:
	# Dotted track from the start position to the end position.
	var base := Vector2.ZERO if Engine.is_editor_hint() else start - position
	var center := size / 2.0
	draw_dashed_line(base + center, base + center + travel, TRACK, 3.0, 10.0)
	draw_circle(base + center, 5.0, TRACK)
	draw_circle(base + center + travel, 5.0, TRACK)

	# The plank itself
	draw_rect(Rect2(Vector2.ZERO, size), WOOD)
	var x := 40.0
	while x < size.x:
		draw_line(Vector2(x, 2), Vector2(x, size.y - 2), WOOD_DARK, 2.0)
		x += 40.0
	draw_rect(Rect2(Vector2.ZERO, size), WOOD_DARK, false, 3.0)
	for nx in [8.0, size.x - 8.0]:
		draw_circle(Vector2(nx, size.y / 2.0), 2.5, WOOD_DARK)
