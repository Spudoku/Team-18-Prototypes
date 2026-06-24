# Implements Minh's custom cursor

extends Node2D
 
const CURSOR_BOX_SIZE = 36.0

func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	_draw_cursor_box(get_global_mouse_position())


func _draw_cursor_box(mouse_position: Vector2) -> void:
	var box_size := Vector2(CURSOR_BOX_SIZE, CURSOR_BOX_SIZE)
	var box := Rect2(mouse_position - box_size * 0.5, box_size)
	var fill_color := Color(0.24, 1.0, 0.74, 0.16)
	var line_color := Color(0.24, 1.0, 0.74, 1.0)

	draw_rect(box, fill_color, true)
	draw_rect(box, line_color, false, 2.0)
