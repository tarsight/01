# Laser.gd (corrigido)
extends Node2D

@export var max_length := 1000.0
@export var thickness := 6.0
@export var alpha := 0.6              # transparência (0..1)
@export var toggle_action := "fireMode"  # sua action já existe
@onready var line: Line2D = $Line2D
@onready var ray: RayCast2D = $RayCast2D
var visible_state := false

func _ready() -> void:
	# garante dois pontos no Line2D (local coordinates)
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.RIGHT * max_length)
	line.width = thickness
	# aplica transparência
	var c = line.modulate
	c.a = alpha
	line.modulate = c

	# RayCast2D: usar alvo local "direita" (será rotacionado pelo Node2D)
	ray.target_position = Vector2.RIGHT * max_length
	ray.enabled = true

	visible_state = false
	visible = false

func _process(_delta: float) -> void:
	# toggle já funcionando por você
	if Input.is_action_just_pressed(toggle_action):
		visible_state = not visible_state
		visible = visible_state

# Player chama update_laser(aim_direction) cada frame
func update_laser(dir: Vector2) -> void:
	# se desligado, não atualiza
	if not visible_state:
		visible = false
		return

	# sem direção válida, esconde
	if dir.length() < 0.001:
		visible = false
		return
	visible = true

	# posiciona o Laser exatamente onde o player está (evita offsets)
	if get_parent() != null:
		global_position = get_parent().global_position

	# ROTACIONA O NÓ do Laser para a direção desejada
	# — e então usa sempre Vector2.RIGHT * max_length como ponto local final.
	rotation = dir.angle()

	# mantém o ray apontando para a direita local (será rotacionado junto)
	ray.target_position = Vector2.RIGHT * max_length
	ray.force_raycast_update()

	# se houve colisão, convertemos ponto world -> local
	if ray.is_colliding():
		var coll_point: Vector2 = ray.get_collision_point()  # world-space
		var local_point: Vector2 = to_local(coll_point)      # converte pro espaço do Laser
		line.set_point_position(1, local_point)
	else:
		# sem colisão: o ponto final local é simplesmente RIGHT * max_length
		line.set_point_position(1, Vector2.RIGHT * max_length)
