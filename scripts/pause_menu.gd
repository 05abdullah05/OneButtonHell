extends Control
# Pause menu, opened with Esc or P (the "pause" input action).

var resume_button: Button


func _ready() -> void:
	# ALWAYS = keeps running while the rest of the game is paused,
	# otherwise the menu could never close itself again.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	resume_button = UIKit.make_button("Resume", resume)
	add_child(UIKit.make_dim())
	add_child(UIKit.make_card([
		UIKit.make_label("PAUSED", 44),
		resume_button,
		UIKit.make_button("Restart", GameManager.restart_level),
		UIKit.make_button("Main Menu", GameManager.go_to_menu),
		UIKit.make_label("Esc to resume", 18, UIKit.SOFT),
	]))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			resume()
		elif not GameManager.level_done:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	get_tree().paused = true      # stops everything that isn't set to ALWAYS
	visible = true
	resume_button.grab_focus()


func resume() -> void:
	get_tree().paused = false
	visible = false
