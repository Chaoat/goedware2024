extends AudioStreamPlayer

@export var volume : float = -15

func _ready() -> void:
	$musicIntro.volume_db = volume
	volume_db = volume

func _on_music_intro_finished() -> void:
	play()

func _on_finished() -> void:
	play()
