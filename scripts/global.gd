extends Node

var lose = false
var win = false
static var maxConvincingness : int = 5

var convincingness : float = maxConvincingness
var skipIntro:bool = false

func _process(_delta: float) -> void:
	if convincingness > maxConvincingness:
		convincingness = maxConvincingness

func addConvincingness(amount:float):
	convincingness = convincingness + amount
	if convincingness < 0:
		convincingness = 0
	elif convincingness > maxConvincingness:
		convincingness = maxConvincingness
