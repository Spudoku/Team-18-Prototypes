extends Node2D

@onready var lines: Node2D = $Line2D

# Track if mouse button is pressed
var pressed: bool = false
# Current line being drawn
var current_line: Line2D = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Update pressed state
			pressed = event.pressed
			
			# If pressed draw line
			if pressed:
				current_line = Line2D.new()
				current_line.default_color = Color.AQUA
				current_line.width = 10
				lines.add_child(current_line)
				current_line.add_point(event.position)
				
	elif event is InputEventMouseMotion and pressed:
		current_line.add_point(event.position)
			
