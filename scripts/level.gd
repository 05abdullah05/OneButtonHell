class_name Level
extends Node2D
# Attach to the ROOT node of every level.
# The root's _ready runs after all its children are ready, so by now
# every coin has joined the "coins" group and the player exists.

enum Palette { DAY, SUNSET, DUSK, NIGHT }

# Turn on from level 4: the player gets one extra jump in the air.
@export var double_jump: bool = false
# Length of the run in pixels, for the progress bar. 0 = measure from the
# start to the goal's x. Set it for levels where the player turns around.
@export var path_length: float = 0.0
# The world's colors: each pair of levels gets its own time of day, so the
# player can see the game progressing (day -> sunset -> dusk -> night).
@export var palette: Palette = Palette.DAY

const PALETTES := {
	Palette.SUNSET: {"sky": Color("f6ad7b"), "far": Color("d98fa0"), "bush": Color("6b8f3f"), "cloud": Color("fff1e6")},
	Palette.DUSK:   {"sky": Color("6b5b95"), "far": Color("8d7ab8"), "bush": Color("2f5d50"), "cloud": Color("d6c8ee")},
	Palette.NIGHT:  {"sky": Color("26335c"), "far": Color("3a4878"), "bush": Color("1f3d36"), "cloud": Color("5d6890")},
}


func _ready() -> void:
	_apply_palette()
	var total := get_tree().get_nodes_in_group("coins").size()
	GameManager.start_level(scene_file_path, total)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.set_air_jumps(1 if double_jump else 0)


func _apply_palette() -> void:
	if palette == Palette.DAY:
		# Day = the original colors already set in the project and Background.
		RenderingServer.set_default_clear_color(
				ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color"))
		return
	var p: Dictionary = PALETTES[palette]
	RenderingServer.set_default_clear_color(p["sky"])
	var far := get_node_or_null("Background/FarHills/Polygon2D")
	if far:
		far.color = p["far"]
	var bush := get_node_or_null("Background/Bushes/Polygon2D")
	if bush:
		bush.color = p["bush"]
	var clouds := get_node_or_null("Background/Clouds")
	if clouds:
		for cloud in clouds.get_children():
			cloud.set("cloud_color", p["cloud"])
