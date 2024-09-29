extends TextureProgressBar

var decay_rate = 1

func _process(delta: float) -> void:
	Global.addConvincingness(-delta * decay_rate)
	value = Global.convincingness
