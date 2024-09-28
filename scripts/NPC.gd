extends CharacterBody3D

@export var NPC_id = 0
@export var walking = true

@export var variants : Resource
@onready var sprite = $Sprite3D

const GRAV = 15
const JUMP = 3.5
const NAV_ACC = 0.5

var speed : float
var spawn_point : Vector3
var map : RID
var prev_pos : Vector3

@onready var nav = $NavigationAgent3D

func _ready(): # Initialisation
	var NPC_texture = "res://sprites/NPCs/NPC_%s.png" % NPC_id
	sprite.texture = load(NPC_texture)
	speed = randf_range(50,200)
	if spawn_point:
		global_position = spawn_point
		
	nav.path_desired_distance = NAV_ACC
	nav.target_desired_distance = NAV_ACC
	prev_pos = global_position
	call_deferred("get_nav_target")
		
func get_nav_target():
	nav.set_target_position(NavigationServer3D.map_get_random_point(map, 1, false))

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
	#ping_pong(delta)
	
	if nav.is_navigation_finished() or prev_pos == global_position:
		get_nav_target()
	
	velocity = global_position.direction_to(nav.get_next_path_position()) * speed * delta
	
	prev_pos = global_position
	move_and_slide()
	
func ping_pong(delta):
	if walking:
		if is_on_wall():
			rotate_y(randf_range(0.5*PI, 1.5*PI))
		velocity = basis.z.normalized() * speed * delta
	else:
		if velocity.x != 0:
			velocity.x = lerpf(velocity.x, 0, 0.15)
		if velocity.z != 0:
			velocity.z = lerpf(velocity.z, 0, 0.15)
	
