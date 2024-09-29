extends Node

var convincingness : float = 100

func _process(delta: float) -> void:
	if convincingness > 100:
		convincingness = 100
