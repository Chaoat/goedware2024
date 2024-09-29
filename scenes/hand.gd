extends TextureRect

var bobbing = false
var bob = 40
const BOB_RATE = 0.3
var start_position : Vector2
var player : CharacterBody3D

@onready var drinks = $Drinks

func _ready() -> void:
	start_position = position
	player = get_tree().root.get_node("Node3D/SubViewportContainer/SubViewport/World/Player")
	player.drinking.connect(player_drank)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		bobbing = true
	if bobbing:
		position.y = lerp(position.y, start_position.y+bob, BOB_RATE)
		if abs(position.y - start_position.y - bob) < 1:
			bobbing = false
	elif position != start_position:
		position = position.lerp(start_position, BOB_RATE)
		
func player_drank(drink):
	print('hand got %s' % drink)
	drinks.texture = load("res://sprites/NPCs/drinks/drink_%s.png" % drink)
	drinks.visible = true
