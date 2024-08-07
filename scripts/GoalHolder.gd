extends Node

signal create_goal
signal game_won

func _ready():
	create_goals()

func create_goals():
	for i in get_child_count():
		var current = get_child(i)
		emit_signal("create_goal", current.max_needed, current.goal_textures, current.goal_string)

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)
	check_game_win()
		
func check_game_win():
	if goals_met():
		print("you won")
		emit_signal("game_won")

func goals_met():
	for i in get_child_count():
		if !get_child(i).goal_met:
			return false
	return true

# check_goal in grid should connect to GoalHolder
func _on_grid_check_goal(goal_type):
	check_goals(goal_type)


func _on_bars_holder_check_goal(goal_type):
	check_goals(goal_type)
