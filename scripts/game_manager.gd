extends Node
# Game manager, registered as the autoload "GameManager".
# Survives scene changes, so it remembers coins, deaths and best results,
# and it is the ONE place that knows the order of the levels.

signal coins_changed(collected: int, total: int)
signal level_completed

# All levels in play order. Add new levels here as you build them.
const LEVELS: Array[String] = [
	"res://scenes/levels/level_01.tscn",
]
const MAIN_MENU := "res://scenes/ui/main_menu.tscn"

var current_level: String = ""   # file path of the level being played
var coins_collected: int = 0     # coins picked up in THIS attempt
var coins_total: int = 0         # coins that exist in the level
var deaths: int = 0              # deaths in the current level
var level_done: bool = false     # true after reaching the goal
var best_coins: Dictionary = {}  # level path -> most coins in one finished run


# Called by every level when it starts (also after each restart).
func start_level(level_path: String, total_coins: int) -> void:
	get_tree().paused = false     # a new scene should never start paused
	if level_path != current_level:
		# A different level than before: start counting deaths from zero.
		current_level = level_path
		deaths = 0
	coins_collected = 0
	coins_total = total_coins
	level_done = false
	coins_changed.emit(coins_collected, coins_total)


func collect_coin() -> void:
	coins_collected += 1
	coins_changed.emit(coins_collected, coins_total)


func add_death() -> void:
	deaths += 1


func complete_level() -> void:
	level_done = true
	best_coins[current_level] = maxi(get_best_coins(current_level), coins_collected)
	level_completed.emit()


func get_best_coins(level_path: String) -> int:
	return best_coins.get(level_path, 0)


func has_next_level() -> bool:
	var i := LEVELS.find(current_level)
	return i >= 0 and i < LEVELS.size() - 1


# --- Navigation, used by the menu buttons ---

func go_to_next_level() -> void:
	var i := LEVELS.find(current_level)
	if i >= 0 and i < LEVELS.size() - 1:
		_change_scene(LEVELS[i + 1])


# fresh = true when replaying after finishing: start the death count over.
func restart_level(fresh: bool = false) -> void:
	if fresh:
		deaths = 0
	get_tree().paused = false
	get_tree().reload_current_scene.call_deferred()


func go_to_menu() -> void:
	if ResourceLoader.exists(MAIN_MENU):
		_change_scene(MAIN_MENU)
	else:
		push_warning("Main menu not built yet, restarting the level instead.")
		restart_level(true)


func _change_scene(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(path)
