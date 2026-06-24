extends Node2D

@onready var lines: Node2D = $Line2D

# Check if the left mouse button is pressed
var pressed: bool = false
# Store the current line being drawn
var current_line: Line2D = null
# Indicate whether the line drawing is finished
var finished_line = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			
			if pressed:
				finished_line = false
				current_line = Line2D.new()
				current_line.default_color = Color.AQUA
				current_line.width = 10
				lines.add_child(current_line)
				current_line.add_point(event.position)
			else:
				finished_line = true
				
	# Handle mouse motion events to add points to the current line
	elif event is InputEventMouseMotion and pressed:
		current_line.add_point(event.position)
