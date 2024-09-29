extends Node

var convincingness : float = 100

func _process(delta: float) -> void:
	if convincingness > 100:
		convincingness = 100

func addConvincingness(amount:float):
	convincingness = convincingness + amount
	if convincingness < 0:
		convincingness = 0
	elif convincingness > 100:
		convincingness = 100
