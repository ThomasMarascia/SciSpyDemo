extends Node

var level_info = {}
var default_level_info = {
	1:{
		"unlocked": true,
		"high_score": 0,
		"stars_unlocked": 0
	}
}
@onready var path = "user://save.dat"

# Called when the node enters the scene tree for the first time.
func _ready():
	if load_data() != null:
		level_info = load_data()
	level_info = default_level_info
	save_data()

	
# changes to save_data and load_data taken from 
# https://forum.godotengine.org/t/solved-how-do-you-do-file-new-in-4x/2758/3
func save_data():
	# changed from video because of new version of Godot
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(var_to_str(level_info))
	file.close()
	
func load_data():
	# also changed for new version of godot
	if FileAccess.open(path, FileAccess.READ) == null:
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var err = str_to_var(content)
	if err != null: 
		var data_received = err
		if typeof(data_received) == TYPE_DICTIONARY: 
			print(data_received) # Prints dictionary 
		else: 
			print("Unexpected data")
	var read = str_to_var(content)
	return read
