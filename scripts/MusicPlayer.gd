extends Node2D

func play_match_noise():
	SoundManager.play_fixed_sound(1)
	
func play_random_noise():
	SoundManager.play_random_sound()


func _on_grid_play_sound():
	play_random_noise()
