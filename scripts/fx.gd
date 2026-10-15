class_name FX
extends RefCounted
# Helper for one-shot particle bursts, created entirely in code.
# "static" means you call it directly as FX.burst(...) without creating an FX object.


static func burst(parent: Node, pos: Vector2, colors: PackedColorArray,
		amount: int = 12, speed: float = 150.0, direction: Vector2 = Vector2.UP,
		spread: float = 60.0, size: float = 5.0, lifetime: float = 0.5,
		gravity_y: float = 600.0) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = lifetime
	p.explosiveness = 1.0            # all particles at once = a burst
	p.direction = direction
	p.spread = spread                # degrees to each side of direction
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, gravity_y)
	p.scale_amount_min = size * 0.6  # no texture = square pixels, scaled to this size
	p.scale_amount_max = size

	# Particles shrink to nothing over their lifetime.
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = curve

	# Each particle gets a random color from the list.
	var gradient := Gradient.new()
	var offsets := PackedFloat32Array()
	for i in colors.size():
		offsets.append(float(i) / colors.size())
	gradient.offsets = offsets
	gradient.colors = colors
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	p.color_initial_ramp = gradient

	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	# Delete the particle node when it is done, so nothing piles up in memory.
	p.finished.connect(p.queue_free)
