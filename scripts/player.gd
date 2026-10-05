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

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_dead: bool = false


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. Auto-run: the player never controls horizontal movement.
	velocity.x = run_speed

	# 2. Gravity + coyote time.
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		velocity.y += gravity * delta

	# 3. Jump buffer: remember a press for a short moment.
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# 4. Jump if a press is buffered AND we are (or just were) on the ground.
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# 5. Variable jump height: letting go early cuts the upward speed.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

	# 6. Let Godot move the body and resolve collisions.
	move_and_slide()

	# 7. Fell into a gap?
	if global_position.y > death_y:
		die()


func die() -> void:
	if is_dead:
		return
	is_dead = true
	# Instant restart. call_deferred waits until the physics step is finished,
	# because removing physics objects in the middle of one causes errors.
	get_tree().reload_current_scene.call_deferred()
