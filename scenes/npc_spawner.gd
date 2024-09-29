class_name NPCSpawner
extends Node3D

@export var npc : PackedScene

@export var spawn_count = 10
@export var waiter_count = 6
@export var variants = 3

@onready var inside = $Environment/Outside/Inside
@onready var outside = $Environment/Outside

@onready var floor = $Environment/Outside/Inside/Floor
@onready var ground = $Environment/Outside/Ground
@onready var roof = $Environment/House/Roof

var npcList:Array = []
var inside_map : RID
var root : Window

func _ready() -> void:
	call_deferred("custom_setup")
	ground.visible = true
	floor.visible = true
	roof.visible = true
	
func custom_setup():
	inside_map = inside.get_navigation_map()
	#var outside_map = outside.get_navigation_map()
	await get_tree().physics_frame
	root = get_tree().root
	spawn_NPCs(spawn_count)
	spawn_waiters(waiter_count)


func spawn_NPCs(n):
	for x in n:
		x = x%variants
		var i = npc.instantiate()
		i.inside = inside_map
		#i.outside = outside_map
		i.NPC_id = x
		i.spawn_point = NavigationServer3D.map_get_random_point(inside_map, 1, false)
		root.call_deferred("add_child", i)
		npcList.append(i)
		
func spawn_waiters(n):
	for x in n:
		var i = npc.instantiate()
		i.inside = inside_map
		i.NPC_id = -1
		i.drink = x % 6
		i.spawn_point = NavigationServer3D.map_get_random_point(inside_map, 1, false)
		root.call_deferred("add_child", i)
		npcList.append(i)
