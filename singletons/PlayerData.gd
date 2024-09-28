extends Node

# TODO backup data
# TODO move data storage to user space

@onready var json:JSON = JSON.new()
var Data:Dictionary = {}

func PlayerDataExists(username:String):
	var player_files = DirAccess.open("res://playerdata")
	return player_files.file_exists("/" + username + ".json")


func LoadPlayerData(username:String):
	if Data.has(username): return
	
	var data_file = FileAccess.open("res://playerdata/" + username + ".json", FileAccess.READ)
	var error:Error = json.parse(data_file.get_as_text())
	
	if error == OK:
		var player_data = json.data
		Data[username] = player_data
	else:
		print("JSON Parse Error: ", json.get_error_message())
	
	data_file.close()


func SavePlayerData(username:String):
	var save_file = FileAccess.open("res://playerdata/" + username + ".json", FileAccess.WRITE)
	if !Data.has(username):
		# default inventory initialised for new players
		save_file.store_string(str({"Inventory": {}, "Abilities": [], "Armor": []}))
	else:
		save_file.store_string(str(Data[username]))
	save_file.close()
