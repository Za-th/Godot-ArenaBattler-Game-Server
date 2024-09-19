extends Control

# TODO handle auth server being down

var network:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var server_running:bool = false

# playerid:int = [username:String, level:String, {"creaturename": creaturenode:Node3D}]
var player_data:Dictionary = {}

# token:String: username:String
var expected_tokens:Dictionary = {}

@onready var player_verification_process = get_node("PlayerVerification")

var creatures:Dictionary = {
"Rat": preload("res://creatures/rat.tscn"),
"Dog": preload("res://creatures/dog.tscn"),
"Bird": preload("res://creatures/bird.tscn"),
"Cat": preload("res://creatures/cat.tscn")}

func _on_start_pressed():
	if !server_running:
		server_running = true
		
		network.create_server(
			$Menu/PortInput.text.to_int(),
			$Menu/MaxPlayersInput.text.to_int()
		)
		
		multiplayer.multiplayer_peer = network
		
		network.peer_connected.connect(_Peer_Connected)
		network.peer_disconnected.connect(_Peer_Disconnected)
		
		$Started.show()

func _on_stop_pressed():
	if server_running:
		server_running = false
		network.peer_connected.disconnect(_Peer_Connected)
		network.peer_disconnected.disconnect(_Peer_Disconnected)
		for peer_id in multiplayer.get_peers():
			# TODO send disconnection to peers
			RemovePlayer(peer_id)
		network.close()
		
		$Started.hide()


func _Peer_Connected(peer_id:int) -> void:
	player_verification_process.Start(peer_id)


func _Peer_Disconnected(peer_id:int) -> void:
	if player_data.has(str(peer_id)):
		RemovePlayer(peer_id)
		player_data.erase(str(peer_id))


func AddPlayer(username:String, player_id:int, level_path="Hub Level"):
	# Default level is Hub
	if !player_data.has(str(player_id)):
		player_data[str(player_id)] = [username, "Hub Level", {}]
		
	# change player location
	player_data[str(player_id)][1] = level_path
	# players creatures should be removed TODO enforce this
	player_data[str(player_id)][2] = {}
	
	var character = preload("res://player_character.tscn").instantiate()
	character.name = str(player_id)
	character.set_multiplayer_authority(player_id)
	get_node("Loaded Level/" + level_path).add_child(character)


func RemovePlayer(player_id:int):
	# players data
	var data:Array = player_data[str(player_id)]
	
	# TODO check if player exists (not just peer)
	var player_level:String = "Loaded Level/" + data[1]
	get_node(player_level).get_node(str(player_id)).queue_free.call_deferred()
	
	# remove active creatures
	var player_active_creatures = data[2]
	for c_name in player_active_creatures:
		player_active_creatures[c_name].queue_free.call_deferred()


func ServerChangeLevel(from:String, to:String, id:int):
	# players data
	var data:Array = player_data[str(id)]
	
	# TODO err handling if player is coming from a level they shouldnt be in
	if from != data[1]:
		pass
	
	RemovePlayer(id)
	AddPlayer(data[0], id, to)


func ServerAddCreature(creature:String, level:String, player_id:int) -> void:
	var data:Array = player_data[str(player_id)]
	
	if creatures.has(creature):
		# player has creature active already, or has 4 active creatures
		if data[2].has(creature) or data[2].size() >= 4:
			print("Player is trying to add too many creatures or already has it active")
		else:
			var creature_node:Node3D = creatures[creature].instantiate()
			# add node and name for players active creatures
			data[2][creature] = creature_node
			creature_node.name = str(player_id) + " " + creature_node.name
			creature_node.set_multiplayer_authority(player_id)
			get_node("Loaded Level/" + level).add_child(creature_node)
	else:
		print("Player " + str(player_id) + " tried to add creature " + creature + " that server doesnt have")


# Player account verification functions

func PlayerExists(username:String):
	# TODO fix
	return true


func PlayerLoggedIn(username:String):
	for token in player_data.keys():
		if player_data[token][0] == username:
			return true
	return false


# Player token functions

@rpc("authority", "call_remote")
func FetchToken(player_id:int) -> void:
	print("Fetching player token")
	rpc_id(player_id, "FetchToken")

@rpc("any_peer", "call_remote")
func ReturnToken(token:String) -> void:
	print("Player returned token")
	var player_id = multiplayer.get_remote_sender_id()
	player_verification_process.Verify(player_id, token)

@rpc("authority", "call_remote")
func ReturnTokenVerificationResults(player_id:int, result:bool) -> void:
	print("Sending player token verification results")
	rpc_id(player_id, "ReturnTokenVerificationResults", result)


# Every 30 seconds remove tokens that have expired
func _on_token_expiration_timeout():
	if !expected_tokens.is_empty():
		var current_time:float = Time.get_unix_time_from_system()
		var token_time:int
		for i in range(expected_tokens.size()-1, -1, -1):
			var token:String = expected_tokens.keys()[i]
			token_time = float(token.split(" ")[1])
			if current_time - token_time >= 30:
				expected_tokens.erase(token)

