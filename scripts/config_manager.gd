extends Node

# path to save file
@onready var path = "user://config.ini"
# variables for sound/music
var sound_on = true
var music_on = true
# set avatar varible (0 - bree, 1 - matthew, 2 - o-neil)
@export var avatar = 0

func _ready():
	load_config()

func save_config():
	var config = ConfigFile.new()
	config.set_value("audio", "sound", sound_on)
	config.set_value("audio", "music", music_on)
	config.set_value("unique_features", "avatar", avatar)
	
	var err = config.save(path)
	if err != OK:
		print("something went wrong")
		
func load_config():
	var config = ConfigFile.new()
	var default_options = {
			"sound": true, 
			"music": true,
			"avatar": 0
			}
	var err = config.load(path)
	if err != OK:
		return default_options
	var options = {}
	sound_on = config.get_value("audio", "sound", default_options.sound)
	music_on = config.get_value("audio", "music", default_options.music)
	avatar = config.get_value("unique_features", "avatar", default_options.avatar)
	return options
