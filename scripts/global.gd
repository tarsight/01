# global.gd
extends Node

var player
signal freezeEnemies
signal scoreUpdate

var score := 0:
	set(value):
		score = value
		scoreUpdate.emit(value)
