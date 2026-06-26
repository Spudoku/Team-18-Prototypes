extends Node2D

var player_name = ""


# func _unhandled_input(event: InputEvent) -> void:
# 	request_move(event)
# 	pass


# @rpc("any_peer", "call_local")
# func request_move(event: InputEvent):
# 	if multiplayer.is_server():
# 		# handle the input
# 		pass
# 	pass

func setup_multiplayer(player_id: int) -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(player_id)