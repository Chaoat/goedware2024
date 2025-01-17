class_name Tile
extends Node2D

var onGrid = false
var confirmed = false
var gridX = 0
var gridY = 0

var letter: String
var score: int

var placedTime:float = 0.0

const lerpMultiplier:float = 10.0
const lerpLeeway = 0.05
var localPositionLerpMult = 1

var targetPos:Vector2 = Vector2(0, 0)
var targetRotation:float = 0.0

var playback = 0

func _ready():
	var randomChoice = (randi()%9) + 1
	var texturePath:String = "res://sprites/scrabble/tiles/" + String.num_int64(randomChoice) + ".png"
	$EmptyTile.texture = load(texturePath)

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
	
	if position != targetPos:
		position = position + localPositionLerpMult*lerpMultiplier*dt*(targetPos - position)
		#if abs(position - targetPos) <= lerpLeeway:
		#	position = targetPos
	if playback:
		playback -= dt
		if playback <= 0:
			playback = 0
			$click.play()

func isWildtile() -> bool:
	return letter == "?"

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
	playback = randf() /4
	
func confirm():
	confirmed = true

func takeOffGrid():
	onGrid = false
	confirmed = false
