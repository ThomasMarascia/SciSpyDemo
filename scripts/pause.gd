extends "res://scripts/BaseMenuPanel.gd"
	
	
func _on_continue_pressed():
	$AnimationPlayer.play_backwards(&"Slide2/PauseSlide")
	get_tree().paused = false
	slide_out()

func _on_quit_pressed():
	get_tree().quit()

func _on_buttom_ui_pause_game():
	$AnimationPlayer.play(&"Slide2/PauseSlide")
