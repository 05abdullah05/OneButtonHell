@tool
extends Area2D
# A spinning, bobbing coin drawn in code.
# Its hitbox (radius 18) is BIGGER than the drawing (radius 13):
# good things are easy to grab, while spikes have smaller hitboxes.

const GOLD := Color("f6c945")
const GOLD_DARK := Color("b7791f")
const SHINE := Color("fff3b0")
const SPARKLES := [Color("f6c945"), Color("fff3b0"), Color("ffffff")]

var time: float = 0.0
var collected: bool = false


func _ready() -> void:
	add_to_group("coins")
	# Coins spin out of sync, based on where they are placed.
	time = position.x * 0.01
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	var bob := sin(time * 3.0) * 4.0
	# Spin: squeeze the width with cos() so it looks like a 3D coin turning.
	var spin := absf(cos(time * 2.5)) * 0.85 + 0.15
	draw_set_transform(Vector2(0, bob), 0.0, Vector2(spin, 1.0))
	draw_circle(Vector2.ZERO, 13.0, GOLD_DARK)
	draw_circle(Vector2.ZERO, 10.5, GOLD)
	draw_circle(Vector2(-3, -3), 3.5, SHINE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	collected = true
	GameManager.collect_coin()
	Audio.play("coin", -4.0, 0.05)
	FX.burst(get_tree().current_scene, global_position, PackedColorArray(SPARKLES),
			14, 200.0, Vector2.UP, 180.0, 5.0, 0.4, 400.0)
	queue_free()
