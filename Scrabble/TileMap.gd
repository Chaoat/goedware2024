extends TileMap

func _process(_delta):
	if Input.is_action_just_pressed("place"):
		var cell_location
		cell_location = local_to_map(get_global_mouse_position())
		if not placed(cell_location):
			set_cell(0, cell_location, 2, Vector2(0,0))
		if placed(cell_location):
			set_cell(0, cell_location, 2, Vector2(1,0))
		
func placed(cell_location):
	var coords = get_cell_atlas_coords(0, cell_location) # You'll need to debug this since it runs twice per click and always ends up returning false
	print(coords)
	match coords:
		Vector2(1,0):
			return false
		Vector2(0,0):
			return true
	
