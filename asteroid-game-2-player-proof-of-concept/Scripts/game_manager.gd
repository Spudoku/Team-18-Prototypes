extends Node

var Players = {}
var player_ids = []

var player1: int # this player controls horizontal movement
var player2: int # this player controls vertical movement

var movement: Vector2

var asteroid_script: Script

@rpc("any_peer", "call_local", "reliable")
func sync_controls(p1: int, p2: int) -> void:
	player1 = p1
	player2 = p2


#region asteroidHandler
# This object tracks an asteroid, then sends an event to SceneManager 

var asteroid: Node2D
var asteroidTimer = 10

# TODO: parameters?
signal missed_asteroid
signal destroyed_asteroid

func set_asteroid(node: Node2D) -> void:
	asteroid = node
	asteroid_script = asteroid.get_script()
	print("Asteroid set: %s", asteroid_script)

func get_asteroid() -> Node2D:
	return asteroid


func initialize(node: Node2D) -> void:
	set_asteroid(node)
	pass


# When a "new" asteroid appears, trigger this
# This handles 
func new_asteroid() -> void:
	# "spawn" the asteroid
	# set a timer for the asteroid
	await get_tree().create_timer(asteroidTimer).timeout
	asteroid_timeout()
	pass

func asteroid_timeout() -> void:
	missed_asteroid.emit()

func asteroid_destroyed() -> void:
	destroyed_asteroid.emit()
#endregion