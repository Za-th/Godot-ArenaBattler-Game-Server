extends Node

var network:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var gateway_api:SceneMultiplayer = SceneMultiplayer.new()
@onready var gameserver:Control = get_node("../Main")
const PORT:int = 1912


func _ready():
	ConnectToServer()


func _process(_delta):
	if multiplayer == null:
		return
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()


func ConnectToServer() -> void:
	network.create_client("localhost", PORT)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	print("Hub Connection Started")
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)


func _OnConnectionFailed() -> void:
	print("Failed to connect to server hub")


func _OnConnectionSucceeded() -> void:
	print("Connected to server hub")


@rpc("authority", "call_remote")
func ReceiveLoginToken(username:String, token:String) -> void:
	print("Received token " + token)
	# check if player has an account
	if gameserver.PlayerExists(username):
		# check if player has already logged in
		if !gameserver.PlayerLoggedIn(username):
			gameserver.expected_tokens[token] = username
		else:
			print("User " + username + " tried to connect but already logged in")
	else:
		print("User " + username + " tried to connect but account doesn't exist")
