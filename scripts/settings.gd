extends "res://scripts/BaseMenuPanel.gd"

signal back_button
# textures for sound on/off
@export var sound_on_texture: Texture
@export var sound_off: Texture
@export var music_on: Texture
@export var music_off: Texture

# back button on settings pressed
func _on_back_btn_pressed():
	emit_signal("back_button")
	
# functions to update the sound 
func change_sound_texture():
	if ConfigManager.sound_on == true:
		$"MarginContainer/Buttons and Graphics/Buttons/Button1".texture_normal = sound_on_texture
	else:
		$"MarginContainer/Buttons and Graphics/Buttons/Button1".texture_normal = sound_off

func _on_button_1_pressed():
	ConfigManager.sound_on = !ConfigManager.sound_on
	change_sound_texture()
	SoundManager.set_sound_volume()
	ConfigManager.save_config()

func _on_game_menu_read_sound():
	change_sound_texture()
	
# functions to update the music 
func change_music_texture():
	if ConfigManager.music_on == true:
		$"MarginContainer/Buttons and Graphics/Buttons/Button2".texture_normal = music_on
	else:
		$"MarginContainer/Buttons and Graphics/Buttons/Button2".texture_normal = music_off

func _on_game_menu_read_music():
	change_music_texture()

func _on_button_2_pressed():
	ConfigManager.music_on = !ConfigManager.music_on
	change_music_texture()
	SoundManager.set_music_volume()
	ConfigManager.save_config()
