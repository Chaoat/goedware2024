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
var interruptMovement:bool = false

var cameraLookTarget:Vector3

signal drinking(drink)
signal interact(word)

var walk_timer : float = 0
var walk_rate : float = 2 * PI / bob_rate

var lastInputDir:Vector2
func _physics_process(delta):
	clock += delta * bob_rate
	var bob = sin(clock + (PI/bob_rate))/bob_height
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var linear_dir = input_dir.y
	var rot_dir = 0
	if input_dir.x:
		rot_dir = input_dir.x * -rotation_speed * delta
	else:
		rot_dir = lerpf(rot_dir, 0, 0.1)
	
	if interruptMovement == true and input_dir != lastInputDir:
		interruptMovement = false
	
	if linear_dir and interruptMovement == false:
		interruptMovement = false
		lastInputDir = input_dir
		velocity.x = sin(basis.get_euler().y) * speed * linear_dir * delta
		velocity.z = cos(basis.get_euler().y) * speed * linear_dir * delta
		position.y = lerpf(position.y, bob, 0.2)
		walk_timer += delta
		if walk_timer > walk_rate:
			walk_timer = 0
			var walk_sound = get_node("walk%s" % (randi() % 3 + 1))
			walk_sound.pitch_scale = randf_range(0.7, 1)
			walk_sound.play()
	else:
		#velocity = Vector3.ZERO
		walk_timer = 0
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
				elif i.has("word"):
					interact.emit(i["word"])

func unlockCamera():
	cameraLocked = false
	
func lockCamera(lookTarget:Vector3):
	cameraLocked = true
	cameraLookTarget = lookTarget

#func _walk_sound():
