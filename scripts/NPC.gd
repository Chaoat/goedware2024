class_name NPC
extends CharacterBody3D

@export var NPC_id = 0
#@export var variants : Resource
@onready var sprite:Sprite3D = $Sprite3D

const GRAV = 15
const JUMP = 3.5
const NAV_ACC = 0.5

var speed : float
var spawn_point : Vector3
var map : RID
#var outside : RID
var prev_pos : Vector3

var conversationDifficulty:int = 1

var waitTime = 0.0
var waiter : bool = false
var leaving : bool = false
var talking : bool = false
var conversationWon : bool = false
var drink

@onready var nav = $NavigationAgent3D
@onready var platter = $Platter
@onready var drinks = $Platter/Drinks
@onready var shadow = $Shadow

func constructor(npcData : Object):
	speed = npcData.speed
	NPC_id = npcData.id
	conversationDifficulty = npcData.difficulty
	spawn_point = npcData.spawn_point
	map = npcData.map
	
func _ready(): # Initialisation
	sprite.texture = load("res://sprites/NPCs/NPC_%s.png" % NPC_id)
	#speed = randf_range(50,200)
	#speed = randf_range(5,20)
	if spawn_point:
		global_position = spawn_point
		
	if NPC_id == -1:
		waiter = true
		#drink = randi() % 6
		#drink = 0
		platter.visible = true
		drinks.texture = load("res://sprites/NPCs/drinks/drink_%s.png" % drink)
		conversationDifficulty = 0
	else:
		platter.visible = false
		
	nav.path_desired_distance = NAV_ACC
	nav.target_desired_distance = NAV_ACC
	prev_pos = global_position
	call_deferred("get_nav_target")
		
func get_nav_target():
	nav.set_target_position(NavigationServer3D.map_get_random_point(map, 1, false))

func setNavTarget(target:Vector3):
	nav.set_target_position(target)

func interact():
	velocity.y = JUMP
	#if randi() % 2 :
		#$voice_1.pitch_scale = randf()
		#$voice_1.play()
	#else:
		#$voice_2.pitch_scale = randf()
		#$voice_2.play()
	
	if waiter:
		#print('have a drink!')
		waitTime = 2.0
		return({"drink": drink})
	else:
		talking = true

func _physics_process(delta):
	velocity.x = 0
	velocity.z = 0
	
	if velocity.y > 0 or global_position.y > 0:
		velocity.y -= GRAV * delta
	else:
		velocity.y = 0
		position.y = move_toward(position.y, 0, 0.015)
	
	if nav.is_navigation_finished(): #or prev_pos == global_position:
		if not leaving :
			get_nav_target()
		else:
			queue_free()
	
	if not talking and waitTime <= 0.0:
		#var direction = global_position.direction_to(nav.get_next_path_position()) * speed * delta
		#velocity += Vector3(direction.x, 0, direction.z)
		velocity += global_position.direction_to(nav.get_next_path_position()) * speed * delta
	
	if waitTime > 0.0:
		waitTime = waitTime - delta
	
	move_and_slide()
	shadow.global_position.y = 0.1
	
func leave():
	leaving = true
	nav.set_navigation_layer_value(1, false)
	nav.set_navigation_layer_value(2, true)
	match randi() % 3:
		0:
			nav.set_target_position(Vector3(-40,0,0))
		1:
			nav.set_target_position(Vector3(40,0,0))
		2:
			nav.set_target_position(Vector3(0,0,40))


func getFacePosition() -> Vector3:
	var height = sprite.pixel_size*sprite.texture.get_height()
	var lookPosition = position
	lookPosition.y = 0.4*height - 1
	return lookPosition 
