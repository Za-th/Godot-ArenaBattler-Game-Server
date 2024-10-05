extends Node

var player_id:int

func _ready() -> void:
	# TODO handle if visual doesnt exist
	
	player_id = name.split(" ")[0].to_int()


@rpc("any_peer", "call_remote")
func ask_server_to_path(path:PackedVector3Array, to_move_name:String) -> void:
	# TODO check if player is controlling this
	
	var to_move:Node3D = get_parent().get_node("Characters").get_node(to_move_name)
	
	to_move.start_moving(path)


@rpc("any_peer", "call_remote")
func ask_server_to_add_creature(creature:String) -> void:
	# TODO check if player is controlling this
	
	var id:int = multiplayer.get_remote_sender_id()
	get_tree().root.get_node("Main").ServerAddCreature(creature, id)


@rpc("authority", "call_remote")
func server_added_creature(creature_name:String) -> void:
	rpc_id(player_id, "server_added_creature", creature_name)


@rpc("authority", "call_remote")
func player_used_ability(character_name:String, ability:String):
	if multiplayer.get_remote_sender_id() == player_id:
		AbilityHandler.used_ability(self, character_name, ability, player_id)


@rpc("authority", "call_remote")
func server_used_ability(character_name:String, ability:String):
	rpc_id(player_id, "server_used_ability", character_name, ability)


@rpc("any_peer", "call_remote")
func ask_to_stop_moving(character_name:String):
	get_parent().get_node("Characters").get_node(character_name).stop_moving()
