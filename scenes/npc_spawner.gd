extends Node3D

@export var npc : PackedScene

@export var spawn_count = 10
@export var variants = 3

@onready var nav_region = $Environment/NavigationRegion3D
	
func _ready() -> void:
	call_deferred("custom_setup")
	
func custom_setup():
	var map = nav_region.get_navigation_map()
	await get_tree().physics_frame
	
	var root = get_tree().root
	for x in spawn_count:
		x = x%variants
		var i = npc.instantiate()
		i.map = map
		i.NPC_id = x
		i.spawn_point = NavigationServer3D.map_get_random_point(map, 1, false)
		root.call_deferred("add_child", i)
