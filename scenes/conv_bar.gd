extends TextureProgressBar

var decay_rate = 1
var conv : float = 100

func _process(delta: float) -> void:
	conv -= delta * decay_rate
	value = conv
