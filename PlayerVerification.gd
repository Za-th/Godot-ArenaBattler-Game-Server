extends Node

@onready var main_interface:Control = get_parent()

# String: float
var awaiting_verification:Dictionary = {}


func Start(player_id:int) -> void:
	awaiting_verification[player_id] = {"Timestamp": Time.get_unix_time_from_system()}
	main_interface.FetchToken(player_id)


func Verify(player_id:int, token:String) -> void:
	var token_verification:bool = false
	while Time.get_unix_time_from_system() - float(token.split(" ")[1]) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			# add player by username and id
			main_interface.AddPlayer(main_interface.expected_tokens[token], player_id)
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	main_interface.ReturnTokenVerificationResults(player_id, token_verification)
	if token_verification == false: # this is to make sure people are disconnected
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)


# Remove tokens after waiting for 30 seconds
func _on_verification_expiration_timeout():
	var current_time:float = Time.get_unix_time_from_system()
	var start_time:float
	if awaiting_verification != {}:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 10:
				awaiting_verification.erase(key)
				# kick player if still connected
				var connected_peers:Array[int] = Array(multiplayer.get_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key, false)
					main_interface.network.disconnect_peer(key)
	print("Awaiting Verification: " + str(awaiting_verification))
