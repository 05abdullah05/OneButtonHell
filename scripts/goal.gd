extends Area2D
# The finish line. The order of levels lives in GameManager.LEVELS.

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

	body.finish()   # stop running + victory pose
	FX.burst(get_tree().current_scene, global_position + Vector2(0, -200),
			PackedColorArray(CONFETTI), 40, 450.0, Vector2.UP, 50.0, 6.0, 1.2, 700.0)
	Audio.play("goal")
	GameManager.complete_level()   # the level complete screen listens for this
