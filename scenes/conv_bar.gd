extends TextureProgressBar

var decay_rate = 1

func _ready():
	max_value = Global.maxConvincingness

func _process(delta: float) -> void:
	Global.addConvincingness(-delta * decay_rate)
	value = Global.convincingness
