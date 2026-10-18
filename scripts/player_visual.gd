@tool
class_name PlayerVisual
extends Node2D
# Draws and animates the player character in code.
# This node's origin is at the player's FEET, so squash & stretch
# keeps the feet on the ground instead of scaling around the middle.

@export var skin_color: Color = Color("f5c9a3")
@export var hair_color: Color = Color("3b2a20")
@export var shirt_color: Color = Color("7b5cff")
@export var pants_color: Color = Color("2d3748")
@export var shoe_color: Color = Color("1a202c")
@export var run_cycle_speed: float = 14.0   # how fast the legs move

const OUTLINE := Color("1a202c")

var on_floor: bool = true
var vertical_speed: float = 0.0
var moving: bool = true
var celebrating: bool = false
var run_time: float = 0.0


func _process(delta: float) -> void:
	run_time += delta * run_cycle_speed
	# Ease the scale back to normal after a squash/stretch.
	# 1 - exp(-k * delta) makes the easing the same at any frame rate.
	scale = scale.lerp(Vector2.ONE, 1.0 - exp(-12.0 * delta))
	queue_redraw()


# Called by the player every physics frame.
func set_state(floor_now: bool, vy: float, is_moving: bool = true) -> void:
	on_floor = floor_now
	vertical_speed = vy
	moving = is_moving


# Instantly deform; _process eases it back to normal.
func squash(target_scale: Vector2) -> void:
	scale = target_scale


func _draw() -> void:
	var hip_l := Vector2(-5, -18)
	var hip_r := Vector2(5, -18)
	var shoulder_l := Vector2(-12, -34)
	var shoulder_r := Vector2(12, -34)
	var foot_l: Vector2
	var foot_r: Vector2
	var hand_l: Vector2
	var hand_r: Vector2
	var bob := 0.0
	var mouth_open := false

	if celebrating and on_floor and not moving:
		# Victory: feet planted, both arms up, little cheering bounce.
		foot_l = Vector2(-7, 0)
		foot_r = Vector2(7, 0)
		var wave := sin(run_time * 0.6) * 3.0
		hand_l = shoulder_l + Vector2(-7, -15 + wave)
		hand_r = shoulder_r + Vector2(7, -15 - wave)
		bob = -absf(sin(run_time * 0.3)) * 3.0
		mouth_open = true
	elif on_floor:
		# Run cycle: legs swing opposite to each other, arms opposite to legs.
		var s := sin(run_time)
		foot_l = Vector2(-5 + s * 9, -maxf(0.0, -cos(run_time)) * 6)
		foot_r = Vector2(5 - s * 9, -maxf(0.0, cos(run_time)) * 6)
		hand_l = shoulder_l + Vector2(-s * 7, 12)
		hand_r = shoulder_r + Vector2(s * 7, 12)
		bob = -absf(s) * 2.0
	elif vertical_speed < 0.0:
		# Going up: legs tucked, arms raised.
		foot_l = Vector2(-9, -6)
		foot_r = Vector2(7, -10)
		hand_l = shoulder_l + Vector2(-4, -12)
		hand_r = shoulder_r + Vector2(4, -12)
		mouth_open = true
	else:
		# Falling: legs reach down, arms out for balance.
		foot_l = Vector2(-8, 0)
		foot_r = Vector2(8, 0)
		hand_l = shoulder_l + Vector2(-11, -5)
		hand_r = shoulder_r + Vector2(11, -5)
		mouth_open = true

	var b := Vector2(0, bob)

	# Legs + shoes
	_limb(hip_l + b, foot_l, pants_color, 7.0)
	_limb(hip_r + b, foot_r, pants_color, 7.0)
	draw_circle(foot_l + Vector2(2, 0), 4.0, shoe_color)
	draw_circle(foot_r + Vector2(2, 0), 4.0, shoe_color)

	# Body
	var body := Rect2(Vector2(-12, -38) + b, Vector2(24, 22))
	draw_rect(body.grow(2.0), OUTLINE)
	draw_rect(body, shirt_color)

	# Arms + hands
	_limb(shoulder_l + b, hand_l + b, shirt_color, 6.0)
	_limb(shoulder_r + b, hand_r + b, shirt_color, 6.0)
	draw_circle(hand_l + b, 3.5, skin_color)
	draw_circle(hand_r + b, 3.5, skin_color)

	# Head
	var head := Vector2(0, -49) + b
	draw_circle(head, 13.0, OUTLINE)
	draw_circle(head, 11.0, skin_color)

	# Hair: the top half of a circle
	var hair := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		hair.append(head + Vector2(cos(a), sin(a)) * 12.0)
	draw_colored_polygon(hair, hair_color)

	# Eyes look to the right, the direction of running
	for ex in [2.0, 8.0]:
		draw_circle(head + Vector2(ex, 2), 3.0, Color.WHITE)
		draw_circle(head + Vector2(ex + 1.0, 2), 1.6, OUTLINE)

	# Mouth: open "o" in the air or when cheering, small smile otherwise
	if mouth_open:
		draw_circle(head + Vector2(6, 8), 2.2, OUTLINE)
	else:
		draw_line(head + Vector2(3, 8), head + Vector2(8, 7), OUTLINE, 1.5)


# Draws an arm or leg: dark outline first, then the colored limb on top.
func _limb(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, OUTLINE, width + 4.0)
	draw_circle(to, (width + 4.0) / 2.0, OUTLINE)
	draw_line(from, to, color, width)
	draw_circle(to, width / 2.0, color)
