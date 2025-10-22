extends Node2D

var shakeStrength := 0.0
var shakeDecay := 5.0
@onready var camera2d: Camera2D = $Camera2D

func _process(delta: float) -> void:
	if shakeStrength>0:
		camera2d.offset = Vector2(randf_range(-1,1),randf_range(-1,1)) * shakeStrength
		shakeStrength =  max(shakeStrength - shakeStrength * delta, 0)
	else:
		camera2d.offset = Vector2.ZERO

func startShake(stregth:=3.0, decay:=5.0):
	shakeStrength = stregth
	shakeDecay = decay
