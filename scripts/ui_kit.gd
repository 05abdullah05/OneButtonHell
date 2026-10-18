class_name UIKit
extends RefCounted
# Shared helpers that build menu UI in code, so every menu in the game
# (pause, level complete, main menu) has the same look.

const PURPLE := Color("7b5cff")
const GOLD := Color("f6c945")
const DARK := Color("1a202c")
const CARD := Color("2d3748")
const SOFT := Color("cbd5e0")


static func box_style(color: Color, radius: int = 14, border: Color = DARK) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(4)
	s.border_color = border
	s.set_content_margin_all(14)
	return s


static func make_button(text: String, on_pressed: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 58)
	b.add_theme_font_size_override("font_size", 26)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_stylebox_override("normal", box_style(PURPLE))
	b.add_theme_stylebox_override("hover", box_style(PURPLE.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", box_style(PURPLE.darkened(0.2)))
	# The selected button gets a white border, so keyboard players see it.
	b.add_theme_stylebox_override("focus", box_style(Color(0, 0, 0, 0), 14, Color.WHITE))
	b.pressed.connect(on_pressed)
	return b


static func make_label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 8)
	l.add_theme_color_override("font_outline_color", DARK)
	return l


# Semi-transparent black over the game, so the menu stands out.
static func make_dim() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0, 0, 0, 0.55)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return r


# A rounded card in the middle of the screen with the items stacked vertically.
static func make_card(items: Array) -> CenterContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	var style := box_style(CARD, 20)
	style.set_content_margin_all(36)
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	for item in items:
		box.add_child(item)
	panel.add_child(box)
	center.add_child(panel)
	return center
