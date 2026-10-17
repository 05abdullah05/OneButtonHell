class_name Level
extends Node2D
# Attach to the ROOT node of every level.
# The root's _ready runs after all its children are ready, so by now
# every coin has joined the "coins" group and can be counted.


func _ready() -> void:
	var total := get_tree().get_nodes_in_group("coins").size()
	GameManager.start_level(scene_file_path, total)
