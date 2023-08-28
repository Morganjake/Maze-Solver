extends StaticBody2D

var Location = []
var Neighbours = []
var DiagonalNeighbours = []
var SurroundingNeighbours = []
var Value = 0
var SavedPosition = Vector2(0, 0)

var Wall = false
var Checked = false
				
func _ready():
	get_child(1).text = str(Value)
				
func _ToWall():
	Wall = true
	get_child(0).color = Color(0, 0, 0, 1)
	get_child(1).text = ""
	get_parent().WallCount += 1
				
func _ToPath():
	Wall = false
	get_parent().WallCount -= 1
	get_child(0).color = Color.from_hsv(1, 0.4 + 0.6 / get_parent().Max * Value, 1, 1)
	get_child(1).text = str(Value)
	
func ChangeType():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): # LEFT CLICK
		if get_parent().SetStart == true or Input.is_action_pressed("Ctrl"):
			if Wall == true:
				_ToPath()
			get_parent().SetStart = false
			get_parent().Start = str(Location[0]) + " " + str(Location[1])
			get_parent().StartBlock = self
			if get_parent().ToggledCalculate == true:
				get_parent().Calculate()
				
		elif get_parent().SetEnd == true or Input.is_action_pressed("Alt"):
			if Wall == true:
				_ToPath()
			get_parent().SetEnd = false
			get_parent().End = str(Location[0]) + " " + str(Location[1])
			get_parent().EndBlock = self
			if get_parent().ToggledCalculate == true:
				get_parent().Calculate()
				
		else:
			if Wall == false:
				_ToWall()
			
			else:
				_ToPath()
				
			if get_parent().ToggledCalculate == true:
				get_parent().Calculate()
			
func _on_click_button_down():
	ChangeType()

func _on_area_2d_mouse_entered():
	ChangeType()

func _on_neighbour_collider_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	SurroundingNeighbours.append(body)
