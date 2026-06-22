extends Node

var score = 0
var mistakes = 0
var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over:
		print("Game Over! Final Score: %d" % score)

# Check if drawing over line 1
func _on_line_1_mouse_entered() -> void:
	if $Player.pressed:
		score += 1
		$Score.text = "Score: %d" % score

# Check if drawing over line 2
func _on_line_2_mouse_entered() -> void:
	if $Player.pressed:
		score += 1
		$Score.text = "Score: %d" % score
