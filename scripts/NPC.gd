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
var inside : RID
var outside : RID
var prev_pos : Vector3

var leaving : bool = false

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
	nav.set_target_position(NavigationServer3D.map_get_random_point(inside, 1, false))

func interact():
	velocity.y = JUMP
	walking = false
	print('talking to me')
	print(variants.txt[NPC_id])
	leave()

func _physics_process(delta):
	if velocity.y > 0 or global_position.y > 0:
		velocity.y -= GRAV * delta
	else:
		velocity.y = 0
		position.y = move_toward(position.y, 0, 0.015)
	
	if nav.is_navigation_finished(): #or prev_pos == global_position:
		if not leaving :
			get_nav_target()
		#else:
			#print(global_position)
			#print("I left")
			#queue_free()
	
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
	
func leave():
	leaving = true
	#nav.set_navigation_map(outside)
	nav.set_navigation_layer_value(1, false)
	nav.set_navigation_layer_value(2, true)
	nav.set_target_position(Vector3(70,0,0))
	#nav.set_target_position(NavigationServer3D.map_get_random_point(outside, 1, false))
