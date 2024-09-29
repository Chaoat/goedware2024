extends TextureRect

var timer = 0
func _process(delta: float) -> void:
	timer += delta
	var offset = sin(timer) * 2
	texture.noise.fractal_gain = offset
