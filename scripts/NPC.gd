extends CharacterBody3D

@export var NPC_id = 0
@export var walking = true

@export var variants : Resource
@onready var sprite = $Sprite3D

const GRAV = 15
const JUMP = 3.5

var speed
var spawned = false

func _ready():
	var NPC_texture = "res://sprites/NPCs/NPC_%s.png" % NPC_id
	sprite.texture = load(NPC_texture)
	speed = randf_range(1,2)
	if spawned:
		global_position += Vector3(randf_range(0, 10), 0, randf_range(0,10))

func interact():
	velocity.y = JUMP
	walking = false
	print('talking to me')
	print(variants.txt[NPC_id])

func _physics_process(delta):
	if velocity.y > 0 or global_position.y > 0:
		velocity.y -= GRAV * delta
	else:
		velocity.y = 0
		position.y = move_toward(position.y, 0, 0.015)
		
	if walking:
		if is_on_wall():
			rotate_y(randf_range(0.5*PI, 1.5*PI))
		velocity = basis.z.normalized() * speed
	else:
		if velocity.x != 0:
			velocity.x = lerpf(velocity.x, 0, 0.15)
		if velocity.z != 0:
			velocity.z = lerpf(velocity.z, 0, 0.15)
		
	move_and_slide()
	
