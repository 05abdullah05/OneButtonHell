class_name Level
extends Node2D
# Attach to the ROOT node of every level.
# The root's _ready runs after all its children are ready, so by now
# every coin has joined the "coins" group and the player exists.

# Turn on from level 4: the player gets one extra jump in the air.
@export var double_jump: bool = false


func _ready() -> void:
	var total := get_tree().get_nodes_in_group("coins").size()
	GameManager.start_level(scene_file_path, total)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.set_air_jumps(1 if double_jump else 0)
