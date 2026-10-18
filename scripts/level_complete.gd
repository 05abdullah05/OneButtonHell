extends Control
# Level complete screen. Hidden until GameManager says the level is done.

@export var show_delay: float = 0.9   # time to enjoy the confetti first


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	GameManager.level_completed.connect(_on_level_completed)


func _on_level_completed() -> void:
	await get_tree().create_timer(show_delay).timeout
	_build()
	visible = true
	# Fade in instead of popping up instantly.
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)


func _build() -> void:
	var gm := GameManager
	var is_last := not gm.has_next_level()
	var title := "YOU BEAT THE GAME!" if is_last else "LEVEL COMPLETE!"

	var items: Array = []
	items.append(UIKit.make_label(title, 44, UIKit.GOLD))
	items.append(UIKit.make_label("Coins  %d / %d" % [gm.coins_collected, gm.coins_total], 30))
	if gm.coins_total > 0 and gm.coins_collected == gm.coins_total:
		items.append(UIKit.make_label("All coins collected!", 22, UIKit.GOLD))
	items.append(UIKit.make_label("Deaths  %d" % gm.deaths, 30))
	items.append(UIKit.make_label("Best  %d / %d" % [gm.get_best_coins(gm.current_level), gm.coins_total],
			20, UIKit.SOFT))

	var buttons: Array[Button] = []
	if not is_last:
		buttons.append(UIKit.make_button("Next Level", gm.go_to_next_level))
	buttons.append(UIKit.make_button("Replay", gm.restart_level.bind(true)))
	buttons.append(UIKit.make_button("Main Menu", gm.go_to_menu))
	items.append_array(buttons)

	add_child(UIKit.make_dim())
	add_child(UIKit.make_card(items))
	# Preselect the first button: Space/Enter presses it (one-button friendly).
	buttons[0].grab_focus.call_deferred()
