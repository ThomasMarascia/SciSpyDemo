extends "res://scripts/BaseMenuPanel.gd"

signal play_pressed
signal settings_pressed

# start button pressed
func _on_button_1_pressed():
	emit_signal("play_pressed")

# settings button pressed
func _on_button_2_pressed():
	print("Sending print signal")
	emit_signal("settings_pressed")
