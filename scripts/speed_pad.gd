@tool
extends Area2D
# Speed pad: glowing cyan chevrons on the ground. Running over it sets
# the player's speed. Cyan is used for nothing else, so it always means "speed".
# The hitbox is tall, so the player can't accidentally jump over it.

@export var target_speed: float = 380.0

const COLOR := Color("4fd1c5")
const STREAKS := [Color("4fd1c5"), Color("b2f5ea"), Color("ffffff")]

var time: float = 0.0
var used: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	# Glowing strip on the ground
	var pulse := 0.6 + 0.4 * sin(time * 6.0)
	draw_rect(Rect2(-40, -6, 80, 6), Color(COLOR, 0.6 * pulse))
	# Three chevrons ">>>" lighting up one after another, pointing forward
	for i in 3:
		var x := -18.0 + i * 18.0
		var glow := 0.35 + 0.65 * maxf(0.0, sin(time * 8.0 - i * 1.2))
		draw_polyline(PackedVector2Array([
			Vector2(x - 6, -34), Vector2(x + 6, -22), Vector2(x - 6, -10)
		]), Color(COLOR, glow), 5.0)


func _on_body_entered(body: Node2D) -> void:
	if used or not body is Player:
		return
	used = true
	body.set_run_speed(target_speed)
	Audio.play("boost", -3.0)
	FX.burst(get_tree().current_scene, global_position + Vector2(0, -20),
			PackedColorArray(STREAKS), 16, 350.0, Vector2.RIGHT, 25.0, 5.0, 0.4, 0.0)
