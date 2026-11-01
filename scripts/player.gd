class_name Player
extends CharacterBody2D

# --- Tunable values (visible in the Inspector thanks to @export) ---
@export var run_speed: float = 300.0          # pixels per second to the right
@export var jump_velocity: float = -650.0     # negative = upwards in Godot
@export var gravity: float = 1800.0           # pixels per second^2 downwards
@export var jump_cut_multiplier: float = 0.5  # releasing early = shorter jump
@export var coyote_time: float = 0.1          # seconds you can still jump after leaving a ledge
@export var jump_buffer_time: float = 0.1     # seconds a too-early press is remembered
@export var death_y: float = 1000.0           # falling below this line = death
@export var pit_y: float = 480.0              # below this = falling into a pit (sound starts)
@export var death_pause: float = 0.55         # seconds before restarting after death
@export var finish_brake: float = 900.0       # how fast the player stops at the goal
@export var air_jumps: int = 0                # extra jumps in mid-air (1 = double jump), set by the level
@export var air_jump_strength: float = 1.0    # air jump as strong as the ground jump

const DUST := [Color("eee8d5"), Color("cfc6ab"), Color("8fd16f")]
const FEATHERS := [Color("ffffff"), Color("e9d8fd"), Color("d6bcfa")]
const FEET := Vector2(0, 30)                  # offset from center to the feet

@onready var visual: PlayerVisual = $Visual
@onready var camera: ShakeCamera = $Camera2D

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_dead: bool = false
var is_finished: bool = false
var was_on_floor: bool = true
var is_falling_in_pit: bool = false
var air_jumps_left: int = 0
var can_cut_jump: bool = false   # only the GROUND jump can be cut short by releasing
var direction: int = 1               # 1 = running right, -1 = running left (turn arrows)
var distance_travelled: float = 0.0  # for the progress bar in levels that turn around


func _ready() -> void:
	add_to_group("player")   # so the HUD can find the player
	# A new attempt: bring the music back if it was faded out by a pit fall.
	Audio.set_music_ducked(false, 0.5)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. Auto-run. After the goal: brake smoothly to a stop instead.
	if is_finished:
		velocity.x = move_toward(velocity.x, 0.0, finish_brake * delta)
	else:
		velocity.x = run_speed * direction

	# 2. Gravity + coyote time.
	if is_on_floor():
		coyote_timer = coyote_time
		air_jumps_left = air_jumps      # landing refills the air jump
	else:
		coyote_timer -= delta
		velocity.y += gravity * delta

	# 3-5. Jumping (not possible after the goal).
	if not is_finished:
		_handle_jump(delta)

	# 6. Let Godot move the body and resolve collisions.
	# Save the falling speed first: move_and_slide sets it to 0 on landing.
	var fall_speed := velocity.y
	var x_before := global_position.x
	move_and_slide()
	distance_travelled += absf(global_position.x - x_before)

	# 7. Landing: squash + dust, both bigger after a bigger fall.
	var on_floor_now := is_on_floor()
	if on_floor_now and not was_on_floor:
		var amount := clampf(fall_speed / 2000.0, 0.1, 0.35)
		visual.squash(Vector2(1.0 + amount, 1.0 - amount))
		FX.burst(_level(), global_position + FEET, PackedColorArray(DUST),
				int(4 + amount * 20), 140.0, Vector2.UP, 85.0, 5.0, 0.35, 300.0)
		if amount >= 0.3:
			camera.shake(4.0)              # small shake only on hard landings
	was_on_floor = on_floor_now

	# 8. Tell the visual which pose to show.
	visual.set_state(on_floor_now, velocity.y, absf(velocity.x) > 20.0)
	visual.has_air_jump = air_jumps_left > 0   # wings = "you can still jump in the air"

	# 9. Falling into a pit: whistle down and fade the music, like dropping in a well.
	if not is_falling_in_pit and global_position.y > pit_y:
		is_falling_in_pit = true
		Audio.play("fall", -2.0)
		Audio.set_music_ducked(true, 0.8)

	# 10. Ran into the side of a platform = crash. Without this the
	# auto-runner would be stuck pushing against the wall forever.
	if is_on_wall():
		die("wall")
		return

	# 11. Fell far enough = dead.
	if global_position.y > death_y:
		die("fall")


func _handle_jump(delta: float) -> void:
	# A press in mid-air (after coyote time) uses an air jump if one is left.
	# Otherwise the press is buffered for the next ground jump.
	if Input.is_action_just_pressed("jump"):
		if coyote_timer <= 0.0 and air_jumps_left > 0:
			_air_jump()
		else:
			jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Jump if a press is buffered AND we are (or just were) on the ground.
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		can_cut_jump = true
		visual.squash(Vector2(0.7, 1.3))   # stretch tall when taking off
		FX.burst(_level(), global_position + FEET, PackedColorArray(DUST),
				6, 110.0, Vector2.UP, 70.0, 5.0, 0.35, 300.0)
		Audio.play("jump", -6.0, 0.08)

	# Variable jump height: letting go early cuts the upward speed.
	# Only for the ground jump: the air jump always goes full height, because
	# players naturally double-TAP, and a cut air jump was too weak (playtest).
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and can_cut_jump:
		velocity.y *= jump_cut_multiplier
		can_cut_jump = false


func _air_jump() -> void:
	velocity.y = jump_velocity * air_jump_strength
	air_jumps_left -= 1
	jump_buffer_timer = 0.0
	can_cut_jump = false
	visual.squash(Vector2(0.75, 1.25))
	# The wings "burst" into feathers: the ability is used up until landing.
	FX.burst(_level(), global_position + Vector2(-8 * direction, -10), PackedColorArray(FEATHERS),
			12, 160.0, Vector2.DOWN, 70.0, 6.0, 0.5, 200.0)
	Audio.play("double_jump", -5.0, 0.04)


# Called by the level (level.gd): 1 = double jump available.
func set_air_jumps(amount: int) -> void:
	air_jumps = amount
	air_jumps_left = amount


# Called by speed pads. The camera looks further ahead at higher speed,
# so the player still gets the same reaction time to see obstacles.
func set_run_speed(new_speed: float) -> void:
	run_speed = new_speed
	camera.set_look_ahead(new_speed * direction)


# Called by turn arrows: run the other way. The character flips around and
# the camera swings to look ahead in the new direction.
func set_direction(new_direction: int) -> void:
	direction = new_direction
	visual.facing = new_direction
	camera.set_look_ahead(run_speed * direction)


# Called by the goal: stop running and celebrate.
func finish() -> void:
	is_finished = true
	visual.celebrating = true


# cause: "spike" (default, used by spikes), "wall" (crash) or "fall" (pits).
func die(cause: String = "spike") -> void:
	if is_dead or is_finished:
		return
	is_dead = true
	velocity = Vector2.ZERO
	GameManager.add_death(global_position, cause)

	# Burst into pieces in the character's own colors.
	visual.visible = false
	FX.burst(_level(), global_position, PackedColorArray([
			visual.shirt_color, visual.skin_color, visual.hair_color, visual.pants_color]),
			30, 420.0, Vector2.UP, 180.0, 7.0, 0.8, 900.0)
	camera.shake(14.0)
	if cause != "fall":
		Audio.play("death")
	# (a pit fall already played its whistle, so no extra sound)

	# Hit-stop: almost freeze the game for a split second so the hit "lands".
	# The timer ignores time_scale, otherwise it would also be slowed down.
	Engine.time_scale = 0.05
	await get_tree().create_timer(0.08, true, false, true).timeout
	Engine.time_scale = 1.0

	# Short pause so the player sees what happened, then restart.
	await get_tree().create_timer(death_pause).timeout
	get_tree().reload_current_scene.call_deferred()


# Particles are added to the level, not the player, so they stay
# where they spawned instead of following the player around.
func _level() -> Node:
	return get_tree().current_scene
