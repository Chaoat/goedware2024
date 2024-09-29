extends Node3D

@export var word : String
@onready var hr = $HourHand
@onready var min = $MinuteHand
const SPEED : float = 0.01

func _process(delta: float) -> void:
	hr.rotate_z(SPEED/12)
	min.rotate_z(SPEED)

func interact():
	return({"word": word})
