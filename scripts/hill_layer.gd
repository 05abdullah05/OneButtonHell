@tool
extends Polygon2D
# Generates a hill or bush silhouette that repeats seamlessly.
# Seamless because each sine wave fits a WHOLE number of times into
# the width, so the left and right edges end at the same height.

@export var width: float = 1600.0:
	set(value):
		width = value
		_rebuild()

@export var base_y: float = 330.0:      # height of the silhouette's base
	set(value):
		base_y = value
		_rebuild()

@export var height: float = 100.0:      # how tall the bumps get
	set(value):
		height = value
		_rebuild()

@export var bumps: int = 2:             # whole number = seamless repeat
	set(value):
		bumps = maxi(value, 1)
		_rebuild()

@export var lumpy: bool = false:        # true = round bush bumps, false = smooth hills
	set(value):
		lumpy = value
		_rebuild()

@export var bottom_y: float = 440.0:    # where the shape ends at the bottom
	set(value):
		bottom_y = value
		_rebuild()

const STEPS := 120


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	var points := PackedVector2Array()
	for i in STEPS + 1:
		var t := float(i) / STEPS          # 0.0 at the left edge, 1.0 at the right
		var wave: float
		if lumpy:
			wave = absf(sin(PI * bumps * t))
		else:
			wave = 0.5 + 0.35 * sin(TAU * bumps * t) + 0.15 * sin(TAU * bumps * 3 * t + 1.0)
		points.append(Vector2(t * width, base_y - wave * height))
	points.append(Vector2(width, bottom_y))
	points.append(Vector2(0, bottom_y))
	polygon = points
