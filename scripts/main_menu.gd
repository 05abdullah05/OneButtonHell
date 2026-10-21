extends Control
# Main menu with three pages: main, levels and credits.
# Each page is built in code; switching page clears and rebuilds the UI.

@export var author_name: String = "Your Name"

var page: String = "main"
var reset_button: Button
var reset_armed: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	show_main()


func _unhandled_input(event: InputEvent) -> void:
	# Esc goes back to the main page.
	if event.is_action_pressed("pause") and page != "main":
		show_main()
		get_viewport().set_input_as_handled()
	# Testing cheat: U on the Levels page unlocks everything (not saved).
	elif page == "levels" and event is InputEventKey and event.pressed \
			and not event.echo and event.keycode == KEY_U:
		GameManager.unlock_all_levels = true
		show_levels()


# --- Pages ---

func show_main() -> void:
	page = "main"
	var start := UIKit.make_button("Start", GameManager.start_game)
	_layout([
		UIKit.make_label("ONE BUTTON HELL", 76),
		UIKit.make_label("One button. Every jump counts.", 24, UIKit.GOLD),
		UIKit.make_spacer(12),
		start,
		UIKit.make_button("Levels", show_levels),
		UIKit.make_button("Credits", show_credits),
		UIKit.make_button("Quit", get_tree().quit),
	])
	start.grab_focus.call_deferred()   # Space starts the game right away


func show_levels() -> void:
	page = "levels"
	reset_armed = false
	var gm := GameManager

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var first_open: Button = null
	for i in gm.LEVELS.size():
		var path := gm.LEVELS[i]
		var b: Button
		if gm.is_unlocked(i):
			var coins := "New!"
			if gm.coin_totals.has(path):
				coins = "%d / %d" % [gm.get_best_coins(path), gm.coin_totals[path]]
			b = UIKit.make_button("Level %d\n%s" % [i + 1, coins], gm.play_level.bind(i))
			if first_open == null:
				first_open = b
		else:
			b = UIKit.make_button("Level %d\nLocked" % (i + 1), func() -> void: pass)
			b.disabled = true
		b.custom_minimum_size = Vector2(170, 90)
		grid.add_child(b)

	var back := UIKit.make_button("Back", show_main)
	reset_button = UIKit.make_button("Reset Progress", _on_reset_pressed)
	_layout([
		UIKit.make_label("LEVELS", 56),
		grid,
		UIKit.make_spacer(8),
		back,
		reset_button,
		UIKit.make_label("Esc = back", 18, UIKit.SOFT),
	])
	(first_open if first_open else back).grab_focus.call_deferred()


func show_credits() -> void:
	page = "credits"
	var back := UIKit.make_button("Back", show_main)
	_layout([
		UIKit.make_label("CREDITS", 56),
		UIKit.make_label("One Button Hell", 30, UIKit.GOLD),
		UIKit.make_label("Made by " + author_name, 26),
		UIKit.make_label("TDDD23 Game Development\nLinköping University, 2026", 22, UIKit.SOFT),
		UIKit.make_label("Made with Godot Engine 4.7", 22, UIKit.SOFT),
		UIKit.make_label("Art, sound effects and music created in code", 22, UIKit.SOFT),
		UIKit.make_spacer(8),
		UIKit.make_label("Space / Left click = Jump      Esc = Pause", 22),
		back,
	])
	back.grab_focus.call_deferred()


# Reset needs two presses, so it can't happen by accident.
func _on_reset_pressed() -> void:
	if not reset_armed:
		reset_armed = true
		reset_button.text = "Sure? Press again"
	else:
		GameManager.reset_progress()
		show_levels()


# Clears the current page and stacks the new items in the screen's upper middle.
func _layout(items: Array) -> void:
	for child in get_children():
		child.queue_free()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_bottom = -170   # stay above the ground at the bottom
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	for item in items:
		box.add_child(item)
	center.add_child(box)
	add_child(center)
