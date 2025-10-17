# global.gd
extends Node

var player
signal scoreUpdate

var score := 0:
	set(value):
		score = value
		scoreUpdate.emit(value)
