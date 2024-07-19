extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().change_scene("res://Scenes/game_menu.tscn")
	pass # Replace with function body.

func _on_grid_game_over():
	$AnimationPlayer.play(&"SlideCrazy")
	pass # Replace with function body.
  
