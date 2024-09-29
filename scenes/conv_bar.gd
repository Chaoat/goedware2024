extends TextureProgressBar

var decay_rate = 1

func _ready():
	max_value = Global.maxConvincingness

var isDecaying = true
func _process(delta: float) -> void:
	if isDecaying:
		Global.addConvincingness(-delta * decay_rate)
		value = Global.convincingness
