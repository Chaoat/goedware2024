extends Node

static var maxConvincingness : int = 200

var convincingness : float = maxConvincingness
var skipIntro:bool = true

func _process(_delta: float) -> void:
	if convincingness > maxConvincingness:
		convincingness = maxConvincingness

func addConvincingness(amount:float):
	convincingness = convincingness + amount
	if convincingness < 0:
		convincingness = 0
	elif convincingness > maxConvincingness:
		convincingness = maxConvincingness
