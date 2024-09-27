extends CharacterBody3D

@export var NPC_id = 0
@export var variants : Resource
@onready var sprite = $Sprite3D

const GRAV = 0.2
const JUMP = 3.5

func _ready():
	var NPC_texture = "res://sprites/NPCs/NPC_%s.png" % NPC_id
	sprite.texture = load(NPC_texture)

func interact():
	velocity.y = JUMP
	print('talking to me')
	print(variants.txt[NPC_id])

func _physics_process(delta):
	if velocity.y > 0 or global_position.y > 0:
		velocity.y -= GRAV
	else:
		velocity.y = 0
		position.y = move_toward(position.y, 0, 0.015)
		
	move_and_slide()
