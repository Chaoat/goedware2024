class_name NPCSpawner
extends Node3D

@export var npcReference : PackedScene
@export var waiter_count = 6

@onready var inside = $Environment/Outside/Inside
@onready var floorReference = $Environment/Outside/Inside/Floor
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
	
	func _init(a, b, c, d) -> void:
		self.id = a
		self.speed = b
		self.difficulty = c
		self.spawn_point = NavigationServer3D.map_get_random_point(d, 1, false)
		self.map = d
		
func _spawn_NPCs():
	npcDataList.append_array([
		npcData.new(2, 70, 1, map), # Worm
		npcData.new(1, 200, 1, map), # Dog
		npcData.new(9, 140, 1, map), # Marble
		npcData.new(3, 90, 2, map), # Cloud
		npcData.new(0, 120, 2, map), # Girl
		npcData.new(7, 80, 2, map), # Robot
		npcData.new(4, 110, 3, map), # Invis
		npcData.new(5, 40, 3, map), # Mouth
		npcData.new(8, 120, 3, map), # Mutant
		npcData.new(6, 100, 4, map), # Man
	])
	
	for i in npcDataList:
		var x = npcReference.instantiate()
		x.constructor(i)
		npcList.append(x)
		call_deferred("add_child", x)
		
func force_leave():
	if not npcList.is_empty():
		if npcList.size() == 1:
			if npcList[0].conversationWon == false:
				return
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
		call_deferred("add_child", x)
		waiterList.append(x)
		
func _ready() -> void:
	call_deferred("custom_setup")
	ground.visible = true
	floorReference.visible = true
	roof.visible = true
	
func custom_setup():
	map = inside.get_navigation_map()
	await get_tree().physics_frame
	root = get_tree().root
	_spawn_NPCs()
	_spawn_waiters(waiter_count)
		
