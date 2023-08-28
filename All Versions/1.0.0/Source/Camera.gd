extends Camera2D

var RightHold = null
var SavedOffset = Vector2(0, 0)

func _ready():
	self.get_parent().get_child(0).get_child(0).color = Color(1, 0.8, 0.8 * log(1 / zoom.x + 1), 1)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom.x *= 1.1
			zoom.y *= 1.1
			self.get_parent().get_child(0).scale = Vector2(1,1) / zoom
			self.get_parent().get_child(0).get_child(0).color = Color(1, 0.8, 0.8 * log(1 / zoom.x + 1), 1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom.x *= 0.9
			zoom.y *= 0.9
			self.get_parent().get_child(0).scale = Vector2(1,1) / zoom
			self.get_parent().get_child(0).get_child(0).color = Color(1, 0.8, 0.8 * log(1 / zoom.x + 1), 1)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			RightHold = DisplayServer.mouse_get_position()
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			RightHold = null
			SavedOffset = offset
			
	elif event is InputEventMouseMotion:
		if RightHold != null:
			offset.x = SavedOffset.x + (RightHold.x - DisplayServer.mouse_get_position().x) * (1 / zoom.x)
			offset.y = SavedOffset.y + (RightHold.y - DisplayServer.mouse_get_position().y) * (1 / zoom.y)
			self.get_parent().get_child(0).position = offset

