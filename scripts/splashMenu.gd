extends Control

const ARENA = preload("uid://uswct46weip8")

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_packed(ARENA)

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
