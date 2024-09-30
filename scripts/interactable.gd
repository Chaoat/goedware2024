extends Node3D

@export var word : String
@onready var hour = $HourHand
@onready var minute = $MinuteHand
const SPEED : float = 0.01

func _process(_delta: float) -> void:
	hour.rotate_z(SPEED/12)
	minute.rotate_z(SPEED)

func interact():
	return({"word": word})
