extends Control

#region onReady
@onready var label = $Label

@onready var hostButton = $HostButton
@onready var joinButton = $JoinButton
@onready var cancelButton = $CancelButton
@onready var startGameButton = $StartGameButton

@onready var roomCodeText = $RoomCode
@onready var usernameText = $Username

#endregion

# Idle: neither joining nor hosting
# idle can go to join or to host via respective buttons
# 
# hosting: from idle using host button. can go back to idle by pressing cancel
# 
# joining: from idle using join button. can go back to idle by pressing cancel
#

@export var Address = "127.0.0.1"
@export var port = 8910

var peer

enum LobbyState {
	IDLE,
	HOSTING,
	JOINING
}

var state = LobbyState.IDLE

func _ready():
	cancelButton.disabled = true
	startGameButton.disabled = true
	state = LobbyState.IDLE

	# server connectivity
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	if "--server" in OS.get_cmdline_args():
		hostGame()
	pass


func _on_cancel_button_button_down() -> void:
	label.text = ""
	state = LobbyState.IDLE
	cancelButton.disabled = true
	startGameButton.disabled = true

	# TODO: destroy peer and/or disconnect from server
	if peer:
		peer.queue_free()

	pass # Replace with function body.


func _on_join_button_button_down() -> void:
	# check room code text
	if roomCodeText.text == "":
		print("Please enter a room code!")
		label.text = "Please enter a room code!"
		return
	# TODO: check if room code is valid
	
	if usernameText.text == "":
		print("Please enter a username!")
		label.text = "Please enter a username!"
		return

	cancelButton.disabled = false
	state = LobbyState.JOINING
	startGameButton.disabled = true

	
	pass # Replace with function body.


func _on_host_button_button_down() -> void:
	label.text = ""
	cancelButton.disabled = false
	state = LobbyState.HOSTING
	startGameButton.disabled = false

	if usernameText.text == "":
		print("Please enter a username!")
		label.text = "Please enter a username!"
		return

	# TODO: generate room code, put it in roomCodeText, create server


	pass # Replace with function body.


func _on_start_game_button_button_down() -> void:
	if state != LobbyState.HOSTING:
		print("You must be hosting to start the game!")
		label.text = "You must be hosting to start the game!"
		return
	
	if usernameText.text == "":
		print("Please enter a username!")
		label.text = "Please enter a username!"
		return

	label.text = ""
	# start the game!
	startGame.rpc()
	pass # Replace with function body.


#region backend

func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)

	if error != OK:
		print("Cannot host!", error)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players!")

	
	pass

@rpc("any_peer", "call_local")
func startGame():
	pass


@rpc("any_peer")
func SendPlayerData(playerName, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": playerName,
			"id": id
		}
	print("Player ", playerName, " has joined the game!")
	# server
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerData.rpc(GameManager.Players[i].name, i)
	pass


func player_connected(id):
	print("Player connected ", id)
	pass

func player_disconnected(id):
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Players")
	for i in players:
		if i.name == str(id):
			i.queue_free()
	pass

func connected_to_server():
	# note: since this passes 1, does that mean its server authority?
	SendPlayerData.rpc_id(1, $Username.text, multiplayer.get_unique_id())

	# TODO: validate roomcode.text
	print("Connected to server with room code", roomCodeText.text)
	label.text = "Connected to server with room code " + roomCodeText.text
	pass

func connection_failed():
	print("Connection failed!")
	label.text = "Connection failed! Please try again..."
	pass
#endregion