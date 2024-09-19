extends Node

@rpc("any_peer", "call_remote")
func ask_server_for_level_change(from:String, to:String):
	# TODO fix
	var id:int = multiplayer.get_remote_sender_id()
	get_tree().root.get_node("Main").ServerChangeLevel(from, to, id)


@rpc("authority", "call_remote")
func ask_server_to_add_creature(creature:String, level:String):
	var player_id:int = multiplayer.get_remote_sender_id()
	get_tree().root.get_node("Main").ServerAddCreature(creature, level, player_id)
