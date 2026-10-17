extends Node
# Game manager, registered as the autoload "GameManager".
# Like the Audio autoload it survives scene reloads, so it can remember
# things across attempts, such as the number of deaths in a level.

signal coins_changed(collected: int, total: int)

var current_level: String = ""   # file path of the level being played
var coins_collected: int = 0     # coins picked up in THIS attempt
var coins_total: int = 0         # coins that exist in the level
var deaths: int = 0              # deaths in the current level


# Called by every level when it starts (also after each restart).
func start_level(level_path: String, total_coins: int) -> void:
	if level_path != current_level:
		# A different level than before: start counting deaths from zero.
		current_level = level_path
		deaths = 0
	coins_collected = 0
	coins_total = total_coins
	coins_changed.emit(coins_collected, coins_total)


func collect_coin() -> void:
	coins_collected += 1
	coins_changed.emit(coins_collected, coins_total)


func add_death() -> void:
	deaths += 1
