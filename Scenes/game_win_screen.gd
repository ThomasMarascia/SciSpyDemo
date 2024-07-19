extends "res://scripts/BaseMenuPanel.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_continue_button_pressed():
	get_tree().reload_current_scene()


func _on_goal_holder_game_won():
	slide_in()
	$AnimationPlayer.play(&"Slide_left")

