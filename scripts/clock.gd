extends Node3D

@onready var hr = $HourHand
@onready var min = $MinuteHand
const SPEED : float = 0.01

func _process(delta: float) -> void:
	hr.rotate_z(SPEED/12)
	min.rotate_z(SPEED)
