class_name Tile
extends Node2D

var onGrid = false
var gridX = 0
var gridY = 0

var letter: String
var score: int

func _init() -> void:
	
	pass

func setStats(inputletter: String, inputScore: int):
	letter = inputletter
	score = inputScore
	$Letter.text = letter
	$Score.text = String.num_int64(score)

func placedOnGrid(x: int, y: int):
	onGrid = true
	gridX = x
	gridY = y

func takeOffGrid():
	onGrid = false
