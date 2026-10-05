extends Area2D

# Pick the next level's .tscn in the Inspector. Empty = replay this level.
@export_file("*.tscn") var next_level: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if next_level == "":
		get_tree().reload_current_scene.call_deferred()
	else:
		get_tree().change_scene_to_file.call_deferred(next_level)
