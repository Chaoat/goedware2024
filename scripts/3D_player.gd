extends CharacterBody3D

@export var speed = 5.0
@export var rotation_speed = 0.05

@onready var interact_ray = $RayCast3D

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var linear_dir = input_dir.y
	var rot_dir = input_dir.x * -rotation_speed
	
	if linear_dir:
		velocity = basis.z.normalized() * speed * linear_dir
	else:
		#velocity = Vector3.ZERO
		velocity.z = move_toward(velocity.z, 0, speed)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		
	rotate_y(rot_dir)
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if interact_ray.is_colliding() and interact_ray.get_collider().has_method("interact"):
			interact_ray.get_collider().interact()
