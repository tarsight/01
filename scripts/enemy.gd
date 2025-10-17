# enemy.gd
extends CharacterBody2D
@onready var sprite := $Sprite2D
var originalColor = Color.WHITE # placeholder para atribuir dps no ready
const BLOOD_PARTICLES = preload("uid://dodcn7r7l4qra")

@export var scorePoints := 10
var player = null
# status
@export var hp := 3
@export var ms := 300.0

# knockback
var kbSpeed := Vector2.ZERO
@export var kbMultiplier := 600.0
@export var kbDecay := 800.0
@export var defaultFlashTime := 0.05

var direction = Vector2.ZERO

func _ready() -> void:
	player = Global.player
	originalColor = sprite.modulate
	
func hitFlash(flashTime: float):
	for piscada in 3: # pisca 3 vezes
		sprite.modulate = Color.TRANSPARENT
		await get_tree().create_timer(flashTime).timeout
		sprite.modulate = originalColor
		await get_tree().create_timer(flashTime).timeout

func _physics_process(delta: float) -> void:
	if kbSpeed.length()>1:
		velocity = kbSpeed
		move_and_slide()
		kbSpeed = kbSpeed.move_toward(Vector2.ZERO, kbDecay * delta)
	else:	
		if player:
			direction = global_position.direction_to(player.global_position)
			velocity = ms * direction
	move_and_slide()
	
func applyKnockback(force: float, sourcePosition: Vector2):
	var kbDir = (position - sourcePosition).normalized()
	kbSpeed = kbDir * force

func takeDMG(amount: int, sourcePosition: Vector2):
	hp -= amount
	applyKnockback(kbMultiplier,sourcePosition)
	hitFlash(defaultFlashTime)
	if hp <= 0:
		var bloodInstance = BLOOD_PARTICLES.instantiate()
		add_sibling(bloodInstance)
		bloodInstance.global_position = global_position
		bloodInstance.rotation = direction.angle() * PI
		queue_free() # trocar por object pooling, so DESTROY objeto se quando nao for mais usado
		Global.score += scorePoints # scorePoints sera passado como param do evento, logo realmente ativa o evento e emite TODOS os eventos conectados ao socreUPdate signal
	print("HP do inimigo:" + str(hp) + "; Dano causado: "+ str(amount))
