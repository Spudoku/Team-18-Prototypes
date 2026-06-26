extends Node2D


#region export
@export var AsteroidScene: PackedScene
@export var LaserIndicatorScene: PackedScene
@export var Player: PackedScene
@export var spawn_noise: AudioStream

@export var laserSpeed = 500
#endregion export


#region onready
@onready var audio_player = $AudioStreamPlayer2D
@onready var clientLabel = $ClientLabel

# @onready var laserPointer = $LaserIndicator
#endregion

var laserIndicator: Node2D

func _ready():
	if multiplayer.is_server():
		clientLabel.text = "I am the host/server"
		spawn_laserPointer()
		for test in GameManager.Players:
			print("player id: " + str(test))
			pass
	else:
		$Timer.stop()
		print("I'm not the server, stopped timer")
		clientLabel.text = "I am a client. My id is: " + str(multiplayer.get_unique_id())
	# else:
	# 	$Timer.start()
	# 	print("I'm the server, started timer")
	# 	spawn_asteroid()
	for i in GameManager.Players:
		var player = Player.instantiate()
		player.name = str(GameManager.Players[i].id)
		add_child(player)
#		set up player authority
		player.setup_multiplayer(GameManager.Players[i].id)
		print("Spawned player named " + player.name)


	assign_controls()
	pass


@rpc("any_peer", "call_local")
func spawn_asteroid():
	if AsteroidScene and multiplayer.is_server():
		var asteroid = AsteroidScene.instantiate()
		var random_x = randf_range(0, get_viewport().size.x)
		var random_y = randf_range(0, get_viewport().size.y)
		asteroid.global_position = Vector2(random_x, random_y)
		asteroid.rotation = randf_range(0, 2 * PI)
		var id = ResourceUID.create_id()
		asteroid.name = "Asteroid_" + str(id) # don't forget to use unique names!
		# asteroid.set_id(id)

		add_child(asteroid)

		# reset noise and play it
		audio_player.stop()
		audio_player.stream = spawn_noise
		audio_player.play()
		
		remove_after_delay(asteroid, 5) # Remove the asteroid after 2-6 seconds


@rpc("any_peer", "call_local")
func spawn_laserPointer():
	if multiplayer.is_server():
		laserIndicator = LaserIndicatorScene.instantiate()

		var x = get_viewport().size.x / 2
		var y = get_viewport().size.y / 2
		laserIndicator.global_position = Vector2(x, y)

		add_child(laserIndicator)

	
func remove_after_delay(node: Node, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(node):
		node.queue_free()


func _on_timer_timeout() -> void:
	spawn_asteroid()
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		var thing_vel = GameManager.movement.normalized() * laserSpeed * delta
		laserIndicator.global_position += thing_vel
	

func assign_controls() -> void:
	if not multiplayer.is_server():
		print("Only the server can handle authority...")
		return
	if GameManager.Players.size() < 2:
		print("There are too few players!")
		return
	elif GameManager.Players.size() > 2:
		print("Weird case: too many players!")
		# TODO: choose 2 random players...
		return
	else:
		print("Just right! exactly 2 players!")
		# TODO: assign controls
		var value = randf()

		if value > 0.5:
			GameManager.player1 = GameManager.player_ids[0]
			GameManager.player2 = GameManager.player_ids[1]
			pass
		else:
			GameManager.player2 = GameManager.player_ids[0]
			GameManager.player1 = GameManager.player_ids[1]
			pass
		
		print("Player 1: " + str(GameManager.player1) + "; Player 2: " + str(GameManager.player2))
		

	pass
