class_name Player3D
extends CharacterBody3D

@export var speed = 400
@export var rotation_speed = 4

@onready var interact_ray = $RayCast3D

var clock = 0
var bob_rate = 12
var bob_height = 5
var player : CharacterBody3D
var cameraLocked : bool = false

var cameraLookTarget:Vector3

signal drinking(drink)

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
	
	if linear_dir:
		velocity.x = sin(basis.get_euler().y) * speed * linear_dir * delta
		velocity.z = cos(basis.get_euler().y) * speed * linear_dir * delta
		position.y = lerpf(position.y, bob, 0.2)
	else:
		#velocity = Vector3.ZERO
		velocity.z = lerpf(velocity.z, 0, 0.5)
		velocity.x = lerpf(velocity.x, 0, 0.5)
		velocity.y = lerpf(velocity.y, 0, 0.5)
		position.y = lerpf(position.y, 0, 0.2)
	move_and_slide()
	
	
	if cameraLocked == false:
		rotate_y(rot_dir)
		rotation.x = lerp_angle(rotation.x, 0, delta)
	else:
		var vecBetween = cameraLookTarget - position
		var xAngle = atan2(vecBetween.y, sqrt(pow(vecBetween.x, 2) + pow(vecBetween.z, 2)))
		var yAngle = atan2(-vecBetween.z, vecBetween.x) - PI/2
		rotation.x = lerp_angle(rotation.x, xAngle, delta)
		rotation.y = lerp_angle(rotation.y, yAngle, delta)

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if interact_ray.is_colliding() and interact_ray.get_collider().has_method("interact"):
			var i = interact_ray.get_collider().interact()
			if i:
				if i.has("drink"):
					drinking.emit(i["drink"])

func unlockCamera():
	cameraLocked = false
	
func lockCamera(lookTarget:Vector3):
	cameraLocked = true
	cameraLookTarget = lookTarget
