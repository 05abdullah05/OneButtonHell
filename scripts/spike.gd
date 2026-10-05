extends Area2D

func _ready() -> void:
	# body_entered is a signal Area2D emits when a physics body overlaps it.
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# The floor also touches the spike, so only react to the player.
	if body is Player:
		body.die()
