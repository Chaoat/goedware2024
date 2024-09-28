extends Node3D

@export var npc : PackedScene

@export var spawn_count = 10
@export var variants = 3

func _ready() -> void:
	var root = get_tree().root
	for x in spawn_count:
		x = x%variants
		print(x)
		var i = npc.instantiate()
		i.NPC_id = x
		i.spawned = true
		root.call_deferred("add_child", i)
		
	
