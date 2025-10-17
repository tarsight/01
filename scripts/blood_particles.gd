extends CPUParticles2D

func _on_timer_timeout() -> void:
	set_physics_process(false)
	set_process(false)
	set_process_internal(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	await get_tree().create_timer(10.0).timeout
	queue_free()
