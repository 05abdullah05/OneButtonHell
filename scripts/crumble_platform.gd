@tool
extends StaticBody2D
# Cracked sandstone that breaks shortly after the player lands on it.
# A thin Trigger area on top detects the player standing on it.
# It comes back after a while, shown as a faint outline until then.

@export var size: Vector2 = Vector2(140, 24):
	set(value):
		size = value
		_update_shape()

@export var crumble_delay: float = 0.5   # seconds of shaking before it breaks
@export var respawn_time: float = 3.0

const SAND := Color("d6b47a")
const SAND_DARK := Color("8a6a3a")
const DEBRIS := [Color("d6b47a"), Color("b08a50"), Color("8a6a3a")]

enum State { SOLID, SHAKING, GONE }
var state: State = State.SOLID


func _ready() -> void:
	_update_shape()
	if Engine.is_editor_hint():
		return
	$Trigger.body_entered.connect(_on_trigger_body_entered)


func _process(_delta: float) -> void:
	if state == State.SHAKING:
		queue_redraw()   # redraw every frame to animate the shaking


func _update_shape() -> void:
	queue_redraw()
	if not is_node_ready():
		return
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = size / 2.0
	# Thin strip on the top surface: only standing on it triggers the crumble.
	var top := RectangleShape2D.new()
	top.size = Vector2(size.x, 12)
	$Trigger/CollisionShape2D.shape = top
	$Trigger/CollisionShape2D.position = Vector2(size.x / 2.0, -2)


func _on_trigger_body_entered(body: Node2D) -> void:
	if state != State.SOLID or not body is Player:
		return
	state = State.SHAKING
	Audio.play("crumble", -4.0, 0.1)
	# false = this timer pauses with the game, so pausing can't break platforms.
	await get_tree().create_timer(crumble_delay, false).timeout
	_break()


func _break() -> void:
	state = State.GONE
	$CollisionShape2D.set_deferred("disabled", true)
	FX.burst(get_tree().current_scene, global_position + size / 2.0,
			PackedColorArray(DEBRIS), 18, 160.0, Vector2.DOWN, 80.0, 7.0, 0.7, 900.0)
	queue_redraw()
	await get_tree().create_timer(respawn_time, false).timeout
	state = State.SOLID
	$CollisionShape2D.set_deferred("disabled", false)
	queue_redraw()


func _draw() -> void:
	if state == State.GONE:
		# Faint outline: shows where it was and that it will come back.
		draw_rect(Rect2(Vector2.ZERO, size), Color(SAND, 0.25), false, 2.0)
		return
	var shake := Vector2.ZERO
	if state == State.SHAKING:
		shake = Vector2(randf_range(-2.5, 2.5), randf_range(-1.5, 1.5))
	draw_set_transform(shake)
	draw_rect(Rect2(Vector2.ZERO, size), SAND)
	draw_rect(Rect2(Vector2.ZERO, size), SAND_DARK, false, 3.0)
	# Zigzag cracks so it looks fragile even before you touch it.
	var x := 25.0
	while x < size.x - 10.0:
		draw_polyline(PackedVector2Array([
			Vector2(x, 0), Vector2(x + 6, size.y * 0.35),
			Vector2(x - 4, size.y * 0.65), Vector2(x + 3, size.y)
		]), SAND_DARK, 2.0)
		x += 45.0
	draw_set_transform(Vector2.ZERO)
