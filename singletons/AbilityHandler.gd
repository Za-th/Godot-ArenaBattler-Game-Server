extends Node

@rpc("any_peer", "call_remote")
func used_ability(user:String, ability:String, selected_enemy:String):
	print(user)
	print(ability)
	print(selected_enemy=="")
