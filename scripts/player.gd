extends CharacterBody2D
class_name Player

# MOVEMENT
@export var max_speed := 300.0
@export var accel := 1500.0
@export var decel := 1200.0
@export var analog_deadzone := 0.01

# AIM
@export var aim_smooth := 12.0
var aim_direction: Vector2 = Vector2.RIGHT

# SHOOT
@export var bullet_prefab: PackedScene
@export var shoot_cd := 0.18
var can_shoot := true

# GAMEPAD AXIS MAPPING (ajuste se necessário)
@export var gp_left_x := 0
@export var gp_left_y := 1
@export var gp_right_x := 2
@export var gp_right_y := 3

# runtime
var move_input := Vector2.ZERO

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	move_input = _get_move_input()
	_apply_movement(delta)
	_update_aim(delta)
	_shoot(aim_direction)

func _process(_delta: float) -> void:
	if has_node("Laser"):
		$Laser.update_laser(aim_direction)

# INPUT
func _get_move_input():
	var digital = Input.get_vector("moveLeft","moveRight","moveTop","moveDown")
	var joy = _get_first_joypad()
	var analog = Vector2.ZERO
	if joy != null:
		analog.x = Input.get_joy_axis(joy, gp_left_x)
		analog.y = Input.get_joy_axis(joy, gp_left_y)
		# se precisar inverter Y (se seu gamepad der Y positivo pra baixo), ajuste aqui
		if analog.length() < analog_deadzone:
			analog = Vector2.ZERO
	if analog != Vector2.ZERO:
		return analog
	else:
		return digital.normalized()

func _get_first_joypad():
	var pads = Input.get_connected_joypads()
	if pads.size() > 0:
		return pads[0]
	return null

# MOVEMENT
func _apply_movement(delta: float) -> void:
	var target_velocity = Vector2.ZERO
	if move_input.length() > 0.001:
		# move_input pode ser analog (magnitude 0..1) ou digital (normalized)
		target_velocity = move_input.normalized() * max_speed * move_input.length()

	# acelera/desacelera suavemente
	if target_velocity.length() > velocity.length():
		velocity = velocity.move_toward(target_velocity, accel * delta)
	else:
		velocity = velocity.move_toward(target_velocity, decel * delta)

	# CLAMP extra: evita overshoot (diagonais mais rápidas)
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_slide()

# AIM
func _update_aim(delta: float) -> void:
	var mouse_dir = (get_global_mouse_position() - global_position)
	var mouse_active = mouse_dir.length() > 0.001
	var joy = _get_first_joypad()
	var right = Vector2.ZERO
	if joy != null:
		right.x = Input.get_joy_axis(joy, gp_right_x)
		right.y = Input.get_joy_axis(joy, gp_right_y)
		if right.length() < analog_deadzone:
			right = Vector2.ZERO

	var desired_dir = Vector2.ZERO
	if right != Vector2.ZERO:
		desired_dir = right.normalized()
	elif mouse_active:
		desired_dir = mouse_dir.normalized()

	if desired_dir != Vector2.ZERO:
		var t = clamp(aim_smooth * delta, 0.0, 1.0)
		aim_direction = aim_direction.lerp(desired_dir, t).normalized()

	if has_node("Gun"):
		$Gun.rotation = aim_direction.angle()

# SHOOT
func _shoot(direction: Vector2) -> void:
	if !Input.is_action_pressed("shoot") or !can_shoot or !aim_direction.length() > 0.001:
		return
	can_shoot = false
	var bullet = bullet_prefab.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(direction)
	await get_tree().create_timer(shoot_cd).timeout
	can_shoot = true
