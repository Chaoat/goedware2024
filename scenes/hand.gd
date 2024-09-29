extends TextureRect

var bobbing = false
var bob = 40
const BOB_RATE = 0.3
var start_position : Vector2
var player : CharacterBody3D

@onready var drinks = $Drinks

func _ready() -> void:
	start_position = position
	player = get_tree().get_root().get_node("./Node3D/Word/Player")

func _process(delta: float) -> void:
	print(bobbing)
	if Input.is_action_just_pressed("interact"):
		bobbing = true
	if bobbing:
		position.y = lerp(position.y, start_position.y+bob, BOB_RATE)
		print(position.y)
		print(start_position.y + bob)
		if abs(position.y - start_position.y - bob) < 1:
			bobbing = false
	elif position != start_position:
		position = position.lerp(start_position, BOB_RATE)
		
		
