extends Area2D
class_name Bullet

@export var speed := 800.0
@export var lifetime := 3.0
var direction := Vector2.RIGHT # direção local (unidade)

func _ready() -> void:
	rotation = direction.angle()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += direction * speed * delta

func set_direction(new_direction: Vector2) -> void:
	if new_direction.length() > 0.001:
		direction = new_direction.normalized()
		rotation = direction.angle()

func _on_screen_notifier_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("takeDMG"):
			body.takeDMG(1, global_position)
		else:
			print("nao foi achado o metodo takeDMG")
		queue_free()
