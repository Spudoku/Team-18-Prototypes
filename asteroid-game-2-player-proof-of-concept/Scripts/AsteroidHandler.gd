extends Node

# This object tracks an asteroid, then sends an event to SceneManager 

var asteroid: Node2D
var asteroidTimer = 10

# TODO: parameters?
signal missed_asteroid

func set_asteroid(node: Node2D) -> void:
	asteroid = node

func get_asteroid() -> Node2D:
	return asteroid


func initialize(node: Node2D) -> void:
	set_asteroid(node)
	pass


# When a "new" asteroid appears, trigger this
# This handles 
func new_asteroid_event() -> void:
	# "spawn" the asteroid
	# set a timer for the asteroid
	await get_tree().create_timer(asteroidTimer).timeout
	asteroid_timeout()
	pass

func asteroid_timeout() -> void:
	missed_asteroid.emit()
