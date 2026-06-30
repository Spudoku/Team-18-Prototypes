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

var last_sent_horiz: float = 0.0
var last_sent_vert: float = 0.0

var center: Vector2

var updated_roles = false

func _ready():
	updated_roles = false
	if multiplayer.is_server():
		clientLabel.text = "I am the host/server"
		spawn_laserPointer()
		
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

	AsteroidHandler.missed_asteroid.connect(penalize_players) # connect to "missed asteroid" event
	pass


func asteroid_timer() -> void:
	pass

# generates THE asteroid 
# key difference is that a single asteroid object will be used
@rpc("any_peer", "call_local")
func spawn_asteroid():
	if AsteroidScene and multiplayer.is_server():
		var asteroid = AsteroidScene.instantiate()
		var random_x = get_viewport().size.x / 2
		var random_y = get_viewport().size.y / 2
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
		
		# remove_after_delay(asteroid, 5) # Remove the asteroid after 2-6 seconds


@rpc("any_peer", "call_local")
func spawn_laserPointer():
	if multiplayer.is_server():
		laserIndicator = LaserIndicatorScene.instantiate()

		var x = get_viewport().size.x / 2
		var y = get_viewport().size.y / 2
		laserIndicator.global_position = Vector2(x, y)

		add_child(laserIndicator)

func penalize_players():
	pass
	
func remove_after_delay(node: Node, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(node):
		node.queue_free()


func _on_timer_timeout() -> void:
	spawn_asteroid()
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and is_instance_valid(laserIndicator):
		# Server securely processes movement from compiled inputs
		var thing_vel = GameManager.movement.normalized() * laserSpeed * delta
		laserIndicator.global_position += thing_vel


func _process(delta: float) -> void:
	var my_id = multiplayer.get_unique_id()
	
	# --- Player 1: Horizontal Input Polling ---
	if my_id == GameManager.player1:
		var horiz = Input.get_axis("ui_left", "ui_right")
		if horiz != last_sent_horiz:
			last_sent_horiz = horiz
			update_horiz_movement.rpc_id(1, horiz) # Send directly to server
			
	# --- Player 2: Vertical Input Polling ---
	elif my_id == GameManager.player2:
		var vert = Input.get_axis("ui_up", "ui_down")
		if vert != last_sent_vert:
			last_sent_vert = vert
			update_vert_movement.rpc_id(1, vert) # Send directly to server

	if not updated_roles:
		if GameManager.player1 != 0 and GameManager.player2 != 0: # if I don't do this, then there is a race condition where player1/player2 aren't initialized
			if my_id == GameManager.player1:
				clientLabel.text = clientLabel.text + "\n You are player 1! You handle horizontal controls!"
			elif my_id == GameManager.player2:
				clientLabel.text = clientLabel.text + "\n You are player 2! You handle vertical controls!"
			else:
				clientLabel.text = clientLabel.text + "\n You have not been assigned controls!"
			
			updated_roles = true

@rpc("any_peer", "call_local", "unreliable")
func update_horiz_movement(value: float):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()

		# handle "sender is host" case
		if sender_id == 0:
			sender_id = 1

		if sender_id == GameManager.player1:
			GameManager.movement.x = value

@rpc("any_peer", "call_local", "unreliable")
func update_vert_movement(value: float):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()

		# handle "sender is host" case
		if sender_id == 0:
			sender_id = 1
		if sender_id == GameManager.player2:
			GameManager.movement.y = value
	

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
		var p1: int
		var p2: int

		if value > 0.5:
			p1 = GameManager.player_ids[0]
			p2 = GameManager.player_ids[1]
			pass
		else:
			p2 = GameManager.player_ids[0]
			p1 = GameManager.player_ids[1]
			pass
		
		print("Player 1: " + str(GameManager.player1) + "; Player 2: " + str(GameManager.player2))
		GameManager.sync_controls.rpc(p1, p2)


	pass
