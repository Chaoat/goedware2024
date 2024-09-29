class_name NPCSpawner
extends Node3D

@export var npcReference : PackedScene

@export var spawn_count = 10
@export var waiter_count = 6
@export var variants = 3

@onready var inside = $Environment/Outside/Inside
@onready var floor = $Environment/Outside/Inside/Floor
@onready var ground = $Environment/Outside/Ground
@onready var roof = $Environment/House/Roof

var npcList : Array = []
var waiterList : Array = []
var npcDataList : Array = []
var map : RID
var root : Window

class npcData:
	var id : int
	var speed : float
	var difficulty : int
	var spawn_point : Vector3
	var map : RID
	
	func _init(id, speed, difficulty, map) -> void:
		self.id = id
		self.speed = speed
		self.difficulty = difficulty
		self.spawn_point = NavigationServer3D.map_get_random_point(map, 1, false)
		self.map = map
		
func _spawn_NPCs():
	npcDataList.append_array([
		npcData.new(0, 120, 1, map), # Girl
		npcData.new(1, 200, 1, map), # Dog
		npcData.new(2, 70, 2, map), # Worm
		npcData.new(3, 50, 3, map) # Cloud
	])
	
	for i in npcDataList:
		var x = npcReference.instantiate()
		print
		x.constructor(i)
		npcList.append(x)
		root.call_deferred("add_child", x)
		
func force_leave():
	if not npcList.is_empty():
		var npc = npcList.pop_front()
		npc.leave()

func _spawn_waiters(n):
	var waiterDataList = []
	for x in n:
		waiterDataList.append(npcData.new(-1, 100, 0, map))
	for i in n:
		var x = npcReference.instantiate()
		x.constructor(waiterDataList[i])
		x.drink = i % 6
		root.call_deferred("add_child", x)
		waiterList.append(x)
		
func _ready() -> void:
	call_deferred("custom_setup")
	ground.visible = true
	floor.visible = true
	roof.visible = true
	
func custom_setup():
	map = inside.get_navigation_map()
	await get_tree().physics_frame
	root = get_tree().root
	_spawn_NPCs()
	_spawn_waiters(waiter_count)
		
