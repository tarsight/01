extends Area2D

@export var type := "rapidFire"
@onready var sprite_2d: Sprite2D = $Sprite2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.applyPowerUp(type)
		queue_free()
