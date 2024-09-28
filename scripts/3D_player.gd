class_name Player3D
extends CharacterBody3D

@export var speed = 400
@export var rotation_speed = 4

@onready var interact_ray = $RayCast3D

var clock = 0
var bob_rate = 12
var bob_height = 5
var movementLocked:bool = false

func _physics_process(delta):
	clock += delta * bob_rate
	var bob = sin(clock)/bob_height
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var linear_dir = input_dir.y
	var rot_dir = 0
	if input_dir.x:
		rot_dir = input_dir.x * -rotation_speed * delta
	else:
		rot_dir = lerpf(rot_dir, 0, 0.1)
	
	if movementLocked == false:
		if linear_dir:
			velocity = basis.z.normalized() * speed * linear_dir * delta
			position.y = lerpf(position.y, bob, 0.2)
		else:
			#velocity = Vector3.ZERO
			velocity.z = lerpf(velocity.z, 0, 0.5)
			velocity.x = lerpf(velocity.x, 0, 0.5)
			velocity.y = lerpf(velocity.y, 0, 0.5)
			position.y = lerpf(position.y, 0, 0.2)
		move_and_slide()
	
	rotate_y(rot_dir)

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if interact_ray.is_colliding() and interact_ray.get_collider().has_method("interact"):
			interact_ray.get_collider().interact()
			

func lockMovement(locked:bool):
	movementLocked = locked
