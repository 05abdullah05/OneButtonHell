@tool
extends Area2D
# Turn arrow: orange arrows on the ground. Touching it makes the player run
# in this pad's direction. Orange is used for nothing else, so it always
# means "turn around". It can be touched again (loops in the tower).

@export_enum("Left:-1", "Right:1") var direction: int = -1:
	set(value):
		direction = value
		queue_redraw()

const COLOR := Color("ed8936")
const STREAKS := [Color("ed8936"), Color("fbd38d"), Color("ffffff")]

var time: float = 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.6 + 0.4 * sin(time * 6.0)
	draw_rect(Rect2(-40, -6, 80, 6), Color(COLOR, 0.6 * pulse))
	# Three arrows pointing the new direction, lighting up one after another.
	var d := float(direction)
	for i in 3:
		var x := (-18.0 + i * 18.0) * d
		var glow := 0.35 + 0.65 * maxf(0.0, sin(time * 8.0 - i * 1.2))
		draw_polyline(PackedVector2Array([
			Vector2(x - 6 * d, -34), Vector2(x + 6 * d, -22), Vector2(x - 6 * d, -10)
		]), Color(COLOR, glow), 5.0)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player or body.direction == direction:
		return
	body.set_direction(direction)
	Audio.play("turn", -4.0)
	FX.burst(get_tree().current_scene, global_position + Vector2(0, -20),
			PackedColorArray(STREAKS), 14, 300.0, Vector2(direction, 0), 25.0, 5.0, 0.35, 0.0)
