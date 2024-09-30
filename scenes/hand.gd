class_name Hand
extends TextureRect

var bobbing = false
var bob = 40
const BOB_RATE = 0.3
var start_position : Vector2
var player : CharacterBody3D

@onready var drinks = $Drinks

func _ready() -> void:
	start_position = position
	
func _process(_delta: float) -> void:
	if not (Global.win or Global.lose) and Input.is_action_just_pressed("interact"):
		bobbing = true
	if bobbing:
		_bob()
	elif position != start_position:
		position = position.lerp(start_position, BOB_RATE)
			
func _bob():
	position.y = lerp(position.y, start_position.y+bob, BOB_RATE)
	if abs(position.y - start_position.y - bob) < 1:
		bobbing = false
		
func player_drank(drink):
	#drinks.texture = load("res://sprites/NPCs/drinks/drink_%s.png" % drink)
	#drinks.visible = true
	texture = load("res://sprites/NPCs/drinks_final/hand_%s.png" % drink)
	
func finish_drink():
	#drinks.visible = false
	bobbing = true
	texture = load("res://sprites/NPCs/drinks_final/hand_-1.png")
