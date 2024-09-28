class_name Tile
extends Node2D

var onGrid = false
var confirmed = false
var gridX = 0
var gridY = 0

var letter: String
var score: int

var placedTime:float = 0.0

var lerpMultiplier:float = 10.0
var lerpLeeway = 0.01

var targetRotation:float = 0.0
func _process(dt: float) -> void:
	if onGrid and not confirmed:
		placedTime = placedTime + dt
		targetRotation = 0.1*sin(2.5*placedTime)
	else:
		targetRotation = 0.0
	
	if rotation != targetRotation:
		rotation = rotation + lerpMultiplier*dt*(targetRotation - rotation)
		if abs(rotation - targetRotation) <= lerpLeeway:
			rotation = targetRotation

func setStats(inputletter: String, inputScore: int):
	letter = inputletter
	score = inputScore
	$Letter.text = letter
	$Score.text = String.num_int64(score)

func placedOnGrid(x: int, y: int):
	onGrid = true
	gridX = x
	gridY = y
	placedTime = 0.0
	
func confirm():
	confirmed = true

func takeOffGrid():
	onGrid = false
	confirmed = false
