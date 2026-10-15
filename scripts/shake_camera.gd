class_name ShakeCamera
extends Camera2D
# Screen shake: randomly offsets the camera, fading out quickly.

@export var shake_decay: float = 6.0    # higher = shake stops faster

var shake_strength: float = 0.0
var base_offset: Vector2


func _ready() -> void:
	base_offset = offset   # remember the normal offset (300, 0)


func shake(amount: float) -> void:
	# Use the strongest shake if several happen at once.
	shake_strength = maxf(shake_strength, amount)


func _process(delta: float) -> void:
	if shake_strength > 0.1:
		shake_strength = lerpf(shake_strength, 0.0, 1.0 - exp(-shake_decay * delta))
		offset = base_offset + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
	else:
		shake_strength = 0.0
		offset = base_offset
