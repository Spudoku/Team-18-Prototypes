extends Node2D

var score = 0
var mistakes = 0 # Currently unused
var game_over = false
# Points threshold to determine if the drawn line is close enough to the target line currently 80 pixels
var threshold = 80
var line_1_drawn = false
var line_2_drawn = false
# Line being drawn by the player
var player_line = null
# Collision active at start
var line_1_collision = true
var line_2_collision = true

# Hide the default mouse cursor
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	if line_1_drawn and line_2_drawn:
		on_game_over()

func on_game_over():
	print("Game Over! Final Score: %d" % score)
	set_process(false)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if check_if_drawing_line_1():
				line_1_drawn = true
			elif check_if_drawing_line_2():
				line_2_drawn = true
			
			if $Player.lines.get_child_count() > 0:
				player_line = $Player.lines.get_child(0)
				$Player.lines.remove_child(player_line)


func check_if_drawing_line_1() -> bool:
	if $Player.finished_line and line_1_collision:

		# Get the player's drawn line and its start and end points
		player_line = $Player.lines.get_child(0)
		var start_point_local = player_line.get_point_position(0)
		var end_point_local = player_line.get_point_position(player_line.get_point_count() - 1)
		var start_point = player_line.to_global(start_point_local)
		var end_point = player_line.to_global(end_point_local)
		# Get the target line's start and end points
		var target_start = $Line1/CollisionShape2D.to_global($Line1/CollisionShape2D.shape.a)
		var target_end = $Line1/CollisionShape2D.to_global($Line1/CollisionShape2D.shape.b)

		if start_point.distance_to(target_start) <= threshold and end_point.distance_to(target_end) <= threshold:
			$Line1/Line2D.default_color = Color.AQUA
			score += 1
			$Score.text = "Score: %d" % score
			# Disable the collision shape for line 1 to prevent further drawing
			$Line1/CollisionShape2D.set_deferred("disabled", true)
			line_1_collision = false
			return true

	return false

func check_if_drawing_line_2() -> bool:
	if $Player.finished_line and line_2_collision:

		# Get the player's drawn line and its start and end points
		player_line = $Player.lines.get_child(0)
		var start_point_local = player_line.get_point_position(0)
		var end_point_local = player_line.get_point_position(player_line.get_point_count() - 1)
		var start_point = player_line.to_global(start_point_local)
		var end_point = player_line.to_global(end_point_local)
		# Get the target line's start and end points
		var target_start = $Line2/CollisionShape2D.to_global($Line2/CollisionShape2D.shape.a)
		var target_end = $Line2/CollisionShape2D.to_global($Line2/CollisionShape2D.shape.b)

		if start_point.distance_to(target_start) <= threshold and end_point.distance_to(target_end) <= threshold:
			$Line2/Line2D.default_color = Color.AQUA
			score += 1
			$Score.text = "Score: %d" % score
			# Disable the collision shape for line 2 to prevent further drawing
			$Line2/CollisionShape2D.set_deferred("disabled", true)
			line_2_collision = false
			return true

	return false
