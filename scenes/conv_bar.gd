extends TextureProgressBar

var decay_rate = 1

func _process(delta: float) -> void:
	Global.convincingness -= delta * decay_rate
	value = Global.convincingness
