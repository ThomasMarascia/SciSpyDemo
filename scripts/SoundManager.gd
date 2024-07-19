extends Node2D

@onready var music_player = $MusicPlayer
@onready var sound_player = $SoundPlayer

# huge thanks to Pixaby for the royalty free sounds and music
var music = preload("res://music/quirky-romantic-spy-121840.mp3")
var possible_sounds = [
	preload("res://music/happy-pop-2-185287.mp3"),
	preload("res://music/happy-pop-3-185288.mp3"),
	preload("res://music/multi-pop-1-188165.mp3")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_sound_volume()
	set_music_volume()
	play_music()

# https://forum.godotengine.org/t/audiostreamplayer-not-playing-sound-in-game-but-plays-in-editor/11436
# make sure the music and sounds play
func play_music():
	music_player.stream = music
	if music_player.playing == false:
		music_player.play()

func play_random_sound():
	# this code was updated since the video
	# taken from https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
	var rng = RandomNumberGenerator.new()
	var temp = floor(rng.randf_range(0, possible_sounds.size()))
	sound_player.stream = possible_sounds[temp]
	if sound_player.playing == false:
		sound_player.play()
		
func play_fixed_sound(sound):
	sound_player.stream = possible_sounds[sound]
	if sound_player.playing == false:
		sound_player.play()
		
# sets volume based on if user wants sound on/off
func set_sound_volume():
	if ConfigManager.sound_on:
		sound_player.volume_db = 0
	else:
		sound_player.volume_db = -80
		
# sets volume based on if user wants music on/off
func set_music_volume():
	if ConfigManager.music_on:
		music_player.volume_db = -15
	else:
		music_player.volume_db = -80
