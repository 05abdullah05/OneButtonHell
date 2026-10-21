extends Node
# Game manager, registered as the autoload "GameManager".
# Survives scene changes, so it remembers coins, deaths and progress.
# It is the ONE place that knows the order of the levels, and it saves
# progress to a file so it is remembered after closing the game.

signal coins_changed(collected: int, total: int)
signal level_completed

# All levels in play order. Add new levels here as you build them.
const LEVELS: Array[String] = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
]
const MAIN_MENU := "res://scenes/ui/main_menu.tscn"
# user:// is a folder Godot creates for each game on the player's computer.
const SAVE_PATH := "user://save.cfg"

var current_level: String = ""   # file path of the level being played
var coins_collected: int = 0     # coins picked up in THIS attempt
var coins_total: int = 0         # coins that exist in the level
var deaths: int = 0              # deaths in the current level
var level_done: bool = false     # true after reaching the goal

# --- Saved progress ---
var completed: Dictionary = {}    # level path -> true when beaten
var best_coins: Dictionary = {}   # level path -> most coins in one finished run
var coin_totals: Dictionary = {}  # level path -> how many coins the level has
var unlock_all_levels: bool = false   # testing cheat, never saved


func _ready() -> void:
	load_progress()


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
	completed[current_level] = true
	best_coins[current_level] = maxi(get_best_coins(current_level), coins_collected)
	coin_totals[current_level] = coins_total
	save_progress()
	level_completed.emit()


func get_best_coins(level_path: String) -> int:
	return best_coins.get(level_path, 0)


func has_next_level() -> bool:
	var i := LEVELS.find(current_level)
	return i >= 0 and i < LEVELS.size() - 1


# Level 1 is always open; every other level opens when the one before is beaten.
func is_unlocked(index: int) -> bool:
	return index == 0 or unlock_all_levels or completed.has(LEVELS[index - 1])


# --- Saving and loading ---

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "completed", completed.keys())
	cfg.set_value("progress", "best_coins", best_coins)
	cfg.set_value("progress", "coin_totals", coin_totals)
	cfg.save(SAVE_PATH)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return   # no save file yet = first time playing
	for path in cfg.get_value("progress", "completed", []):
		completed[path] = true
	best_coins = cfg.get_value("progress", "best_coins", {})
	coin_totals = cfg.get_value("progress", "coin_totals", {})


func reset_progress() -> void:
	completed.clear()
	best_coins.clear()
	coin_totals.clear()
	unlock_all_levels = false
	save_progress()


# --- Navigation, used by the menu buttons ---

func start_game() -> void:
	_change_scene(LEVELS[0])


func play_level(index: int) -> void:
	_change_scene(LEVELS[index])


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
	current_level = ""   # so deaths start from zero next time a level is played
	_change_scene(MAIN_MENU)


func _change_scene(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(path)
