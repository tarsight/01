class_name Arena
extends Node2D

@onready var scoreLabel: Label = %ScoreLabel
@onready var waveLabel: Label = %WaveLabel

@onready var player: Player = $Player
@export var spawnMargin := 200 # margin basica de 200 pixels
#@export var enemyPrefab : PackedScene

@export var enemyPrefabs:= {
	"A": preload("uid://b615dqt41rbke"),
	"B": preload("uid://c1dmeqcgp20oe"),
	"C": preload("uid://blbq48yoao43w")
}

var powerUpsPrefabs := {
	"megaShot": preload("uid://cqc658g8fqiqx"),
	"rapidFire": preload("uid://do4cij2jhn2v5"),
	"freezeEnemies": preload("uid://dor7401i223ta")
}

var activeEnemies := []
@export var currentWave :=1
@export var enemiesPerWave := 3
@export var timeBetweenEnemies := 0.3
@export var timeBetweenWaves := 1.0
var isSpawning := false

func _ready():
	spawnWave()
	waveLabel.text = "WAVE: "+ str(currentWave)
	updateScoreLabel(Global.score)
	Global.scoreUpdate.connect(updateScoreLabel)

func onEnemyExit(enemy):
	if enemy in activeEnemies:
		activeEnemies.erase(enemy)
		
	if activeEnemies.is_empty():
		nextWave()

func spawnWave():
	if isSpawning:
		return
	isSpawning = true
	waveLabel.text = "WAVE: "+ str(currentWave)
	print("Iniciando spawn da wave:" + str(currentWave))
	for enemy in enemiesPerWave:
		spawnEnemy()
		await get_tree().create_timer(timeBetweenEnemies).timeout
	
func spawnEnemy():
	# var enemy = enemyPrefab.instantiate()
	var enemyPrefab = getEnemyPrefabForWave(currentWave)
	var enemy = enemyPrefab.instantiate()
	add_child(enemy)
	enemy.global_position = calculateSpawnPosition()
	enemy.player = player
	activeEnemies.append(enemy)
	enemy.tree_exited.connect(onEnemyExit.bind(enemy))
	print("inimigo spawnados")
	
func nextWave():
	await get_tree().create_timer(timeBetweenWaves).timeout
	currentWave +=1
	enemiesPerWave +=1
	isSpawning = false
	spawnWave()
	
func getEnemyPrefabForWave(wave: int) -> PackedScene:
	if wave < 3:
		return enemyPrefabs["A"]
	elif wave < 5:
		return enemyPrefabs["B"]
	else:
		return enemyPrefabs["C"]
	

func calculateSpawnPosition() -> Vector2:
	var screenSize = get_viewport().get_visible_rect().size
	var playerPos = player.global_position
	var spawnDistance := screenSize.length()/2 + spawnMargin
	var angle:= randf_range(0, TAU)
	var spawnPos = playerPos + Vector2.RIGHT.rotated(angle) * spawnDistance
	return spawnPos

func updateScoreLabel(score):
	scoreLabel.text = "SCORE: " + str("%02d" %Global.score)


func _on_power_up_spawn_timer_timeout() -> void:
	randomSpawnPowerUp()
	
func randomSpawnPowerUp():
	if randf() > 0.2:
		return
	
	var powerUpIndex = randi() % 3
	var powerUp
	
	if powerUpIndex == 0:
		powerUp = powerUpsPrefabs["rapidFire"].instantiate()
	elif powerUpIndex == 1:
		powerUp = powerUpsPrefabs["megaShot"].instantiate()
	elif powerUpIndex == 2:
		powerUp = powerUpsPrefabs["freezeEnemies"].instantiate()
		
	if powerUp:
		powerUp.position = Vector2(randi_range(100,600), randi_range(100,600))
		add_child(powerUp)
