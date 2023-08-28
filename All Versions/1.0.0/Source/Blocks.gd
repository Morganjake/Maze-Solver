extends Node2D

var BlockDict = {}
var BlockScene = preload("res://block.tscn")
var Random = RandomNumberGenerator.new()

var XSize = 10
var YSize = 10
var SideLen = XSize + YSize - 2
var WallCount = 0
var Max = SideLen
var ToggledCalculate = false
var RandomPath = false

var Start = "0 0"
var StartBlock = null
var SetStart = false
var End = str(XSize - 1) + " " + str(YSize - 1)
var EndBlock = null
var SetEnd = false

func _ready():
	var time = Time.get_unix_time_from_system()
	# Loops through the X and Y sizes to give each block an X and Y value and all of it's neighbours
	# Also makes a block dictionary where the X and Y value are the block's index
	for Y in range(YSize):
		for X in range(XSize):
			var NewBlock = BlockScene.instantiate()
			
			BlockDict[str(X) + " " + str(Y)] = NewBlock
			NewBlock.Location = [X, Y]
			
			NewBlock.position = Vector2(X * 40 - 250, Y * 40 - 250)
			NewBlock.SavedPosition = NewBlock.position
			NewBlock.Value = X + Y
			NewBlock.get_child(0).color = Color.from_hsv(1, 0.4 + 0.6 / SideLen * (X + Y), 1, 1)
			
			if X > 0:
				NewBlock.Neighbours.append(BlockDict[str(X - 1) + " " + str(Y)]) # Adds the neighbour to the left to the list
				BlockDict[str(X - 1) + " " + str(Y)].Neighbours.append(NewBlock) # Adds itself to the neighbour on the left's list
						
			if Y > 0:
				NewBlock.Neighbours.append(BlockDict[str(X) + " " + str(Y - 1)]) # Adds the neighbour above to the list
				BlockDict[str(X) + " " + str(Y - 1)].Neighbours.append(NewBlock) # Adds itself to the above neighbour's list
						
			add_child(NewBlock)

	StartBlock = BlockDict[Start] # Defaults the start block to the block at the top left
	End = str(XSize - 1) + " " + str(YSize - 1)
	EndBlock = BlockDict[End] # Defaults the end block to the block at the bottom right
	
	await get_tree().create_timer(0).timeout
	
	for Block in get_children():
		for Neighbour in Block.SurroundingNeighbours:
			if Neighbour not in Block.Neighbours:
				Block.DiagonalNeighbours.append(Neighbour)
	
	print("Loaded in ",(Time.get_unix_time_from_system() - time) * 1000 , " Milliseconds")

func Calculate():
	var time = Time.get_unix_time_from_system()
	Random.randomize()
	
	for Block in get_children(): # Resets the blocks
		Block.Checked = false
		
	var StepsToReach = 0
	var TotalChecked = 1
	
	var Paths = {StartBlock: [StartBlock]}
	var NextBlocks = [StartBlock]
	StartBlock.Checked = true
	
	while TotalChecked <= XSize * YSize - WallCount: # Loops while all the blocks haven't been checked
		var Neighbours = []
		if RandomPath == true:
			NextBlocks.shuffle()
		for Block in NextBlocks: # Loops all the neighbours of the previous neighbours
			Block.Value = StepsToReach
			for Neighbour in Block.Neighbours: # Loops all of the neighbours of the block
				
				if Neighbour.Checked == false and Neighbour.Wall == false: # Only adds the neighbour to a list if it's not a wall or already checked
					Paths[Neighbour] = Paths[Block].duplicate()       
					Paths[Neighbour].append(Neighbour)
					Neighbour.Checked = true
					Neighbours.append(Neighbour)
						
			TotalChecked += 1
				
		StepsToReach += 1
		if Neighbours == []:
			break
		NextBlocks = Neighbours.duplicate()  # Copies this iteration's neighbours 
		
	Max = StepsToReach
	
	for Block in get_children(): # Change text colour and tween
			
		if Block.Checked == false and Block.Wall == false: # Runs if the block in inaccessable
			Block.get_child(1).text = ""
			Block.get_child(0).color = Color.from_hsv(0, 0, 0.3, 1)
			
		elif Block.Wall == false:
			Block.get_child(1).text = str(Block.Value)
			if EndBlock.Checked and Paths[BlockDict[End]].has(Block): # Runs if the block is in the shortest path
				Block.get_child(1).add_theme_color_override("font_color", Color.from_hsv(0.18, 0.9, 0.9, 1))
				Block.get_child(1).add_theme_font_size_override("font_size", 20)
			else:
				Block.get_child(1).add_theme_color_override("font_color", Color.from_hsv(0, 0, 0, 1))
				Block.get_child(1).add_theme_font_size_override("font_size", 15)
				
			Block.get_child(0).color = Color.from_hsv(1, 0.4 + 0.6 / Max * Block.Value, 1, 1)
			
	print("Path calculated in ", (Time.get_unix_time_from_system() - time) * 1000, " Milliseconds")

func _on_calculate_pressed():
	Calculate()

func _on_randomize_pressed():
	Random.randomize()
	for Block in get_children():
		if Random.randi_range(0, 2) == 0:
			if Block.Wall == false:
				Block._ToWall()
			
	if ToggledCalculate == true:
		Calculate()

func _on_toggle_calculate_pressed():
	ToggledCalculate = true if ToggledCalculate == false else false

func _on_set_start_pressed():
	SetStart = true

func _on_set_end_pressed():
	SetEnd = true

func _on_clear_pressed():
	for Block in get_children():
		Block._ToPath()
		WallCount = 0
	Calculate()

func _on_size_drag_ended(_value_changed):
	for Block in get_children():
		remove_child(Block)
		Block.queue_free()
	_ready()
	if ToggledCalculate == true:
		Calculate()
		
func _on_size_value_changed(value):
	get_parent().get_child(3).get_child(0).get_child(0).text = "Maze Size: " + str(value)
	BlockDict = {}
	XSize = value
	YSize = value
	SideLen = XSize + YSize - 2
	WallCount = 0
	Max = SideLen

func _on_randomize_path_pressed():
	RandomPath = true if RandomPath == false else false

#-----------------------------------------------------------#

func _Fix(Block):
	var Fix = Random.randi_range(0, len(Block.Neighbours) - 1)
	if Block.Neighbours[Fix].Wall == true:
		Block.Neighbours[Fix]._ToPath()
	_Check(Block)

func _Check(Block):
	var PathCount = 0
	for Neighbour in Block.Neighbours:
		if Neighbour.Wall == false:
			PathCount += 1
	if PathCount < 2:
		_Fix(Block)

func _PathMaker():
	var Limit = 8
	for i in range(3):
		for Block in get_children():
			if Block.Wall == false:
				var Checker = 0
				for Neighbour in Block.SurroundingNeighbours:
					if Neighbour.Wall == false:
						Checker += 1
				
				if Checker > Limit:
					Block._ToWall()
			
		Limit -= 1
		
func _on_create_maze_pressed():
	var time = Time.get_unix_time_from_system()
	Random.randomize()
	WallCount = 0
	for Block in get_children():
		Block._ToWall()
		
	for Block in get_children():
		if Random.randi_range(0, 2) == 0:
			Block._ToPath()
			_Check(Block)
	_PathMaker()
	
	for i in range(5):
		for Block in get_children():
			if Random.randi_range(0, 5) == 0 and Block.Wall == true:
				Block._ToPath() 
		_PathMaker()
		
	if BlockDict[Start].Wall == true:
		BlockDict[Start].Wall = false
	if BlockDict[End].Wall == true:
		BlockDict[End].Wall = false
		
	if ToggledCalculate == true:
		Calculate()
	print("Maze created in ", (Time.get_unix_time_from_system() - time) * 1000, " Milliseconds")


