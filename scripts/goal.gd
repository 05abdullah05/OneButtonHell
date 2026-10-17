extends Area2D

# Pick the next level's .tscn in the Inspector. Empty = replay this level.
@export_file("*.tscn") var next_level: String = ""
@export var finish_delay: float = 1.0   # seconds of celebration before moving on

const CONFETTI := [Color("f6e05e"), Color("68d391"), Color("63b3ed"),
		Color("f687b3"), Color("ffffff")]

var reached: bool = false


func _ready() -> void:
	add_to_group("goal")     # so the HUD can find the goal for the progress bar
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if reached or not body is Player:
		return
	reached = true

	# Celebrate: confetti from the top of the flag + fanfare.
	FX.burst(get_tree().current_scene, global_position + Vector2(0, -200),
			PackedColorArray(CONFETTI), 40, 450.0, Vector2.UP, 50.0, 6.0, 1.2, 700.0)
	Audio.play("goal")

	await get_tree().create_timer(finish_delay).timeout
	if next_level == "":
		get_tree().reload_current_scene.call_deferred()
	else:
		get_tree().change_scene_to_file.call_deferred(next_level)
