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
	#resize()
	#get_tree().get_root().size_changed.connect(resize) 
	
	
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
	drinks.texture = load("res://sprites/NPCs/drinks/drink_%s.png" % drink)
	drinks.visible = true
	
func finish_drink():
	drinks.visible = false

## Function to scale the TextureRect based on screen size
#func resize():
	#print(resize)
	#var screen_size = get_viewport().size
	#var scale_factor = 0.0005  # You can adjust this value based on how much you want to scale
	#print(scale)
	## Scale the TextureRect to a percentage of the screen size
	#scale = Vector2(screen_size.y * scale_factor, screen_size.y * scale_factor)
	#rect_size()
