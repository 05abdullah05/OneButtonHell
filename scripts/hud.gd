extends Control
# Heads-up display, drawn in code. It sits inside a CanvasLayer, so it
# stays fixed on the screen instead of moving with the camera.

const FONT_SIZE := 28
const OUTLINE := Color("1a202c")
const BAR_WIDTH := 360.0

var player: Node2D
var goal: Node2D
var start_x: float = 0.0
var progress: float = 0.0
var coin_punch: float = 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # never block clicks (click = jump)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	GameManager.coins_changed.connect(_on_coins_changed)
	# Wait one frame so the whole level exists before looking for nodes.
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	goal = get_tree().get_first_node_in_group("goal")
	if player:
		start_x = player.global_position.x


func _on_coins_changed(collected: int, _total: int) -> void:
	if collected > 0:
		coin_punch = 1.6     # the icon "pops", then shrinks back


func _process(delta: float) -> void:
	coin_punch = lerpf(coin_punch, 1.0, 1.0 - exp(-10.0 * delta))
	if is_instance_valid(player) and is_instance_valid(goal):
		var level := get_tree().current_scene as Level
		var p: float
		if level and level.path_length > 0.0:
			# Levels that turn around: measure distance run, not x position.
			p = player.distance_travelled / level.path_length
		else:
			p = inverse_lerp(start_x, goal.global_position.x, player.global_position.x)
		progress = maxf(progress, clampf(p, 0.0, 1.0))   # never moves backwards
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font

	# --- Coin counter (top left) ---
	draw_set_transform(Vector2(40, 40), 0.0, Vector2.ONE * coin_punch)
	draw_circle(Vector2.ZERO, 15.0, Color("b7791f"))
	draw_circle(Vector2.ZERO, 12.0, Color("f6c945"))
	draw_circle(Vector2(-4, -4), 4.0, Color("fff3b0"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_text(font, Vector2(66, 50), "%d / %d" % [GameManager.coins_collected, GameManager.coins_total])

	# --- Death counter (top right) ---
	_text(font, Vector2(size.x - 230, 50), "Deaths %d" % GameManager.deaths,
			HORIZONTAL_ALIGNMENT_RIGHT, 200.0)

	# --- Progress bar (top center) ---
	var x0 := (size.x - BAR_WIDTH) / 2.0
	var y := 34.0
	draw_rect(Rect2(x0 - 3, y - 3, BAR_WIDTH + 6, 16), Color(0, 0, 0, 0.45))
	draw_rect(Rect2(x0, y, BAR_WIDTH, 10), Color(1, 1, 1, 0.25))
	draw_rect(Rect2(x0, y, BAR_WIDTH * progress, 10), Color.WHITE)
	# Flag at the end = the goal
	var fx := x0 + BAR_WIDTH + 6
	draw_rect(Rect2(fx - 2, y - 16, 4, 30), Color("2f855a"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(fx + 2, y - 16), Vector2(fx + 20, y - 10), Vector2(fx + 2, y - 4)
	]), Color("48bb78"))
	# Player marker (purple, like the shirt)
	var marker := Vector2(x0 + BAR_WIDTH * progress, y + 5)
	draw_circle(marker, 9.0, OUTLINE)
	draw_circle(marker, 7.0, Color("7b5cff"))


func _text(font: Font, pos: Vector2, text: String,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0) -> void:
	draw_string_outline(font, pos, text, align, width, FONT_SIZE, 8, OUTLINE)
	draw_string(font, pos, text, align, width, FONT_SIZE, Color.WHITE)
