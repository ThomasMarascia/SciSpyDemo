extends TextureRect

@onready var score_label = $score
var current_score = 000

@export var goal_prefab: PackedScene
@onready var goal_container = $Goals

@onready var counter_label = $moves
var current_count = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(current_score)

# update_score in grid should connect to top_ui
func _on_grid_update_score(amount_change):
	current_score += amount_change
	$score.text = str(current_score)

func make_goal(new_max, new_texture, new_value):
	var current = goal_prefab.instantiate()
	print(current.get_h_size_flags())
	current.set_h_size_flags(2)
	$Goals.add_child(current)
	current.set_goal_values(new_max, new_texture, new_value)

# create_goal in GoalHolder should connect to top_ui
func _on_goal_holder_create_goal(new_max, new_texture, new_value):
	make_goal(new_max, new_texture, new_value)


# check_goal in grid should connect to top_ui
func _on_grid_check_goal(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

func _on_bars_holder_check_goal(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)


# update counter in grid should connect to top_ui
func _on_grid_update_counter(amount_to_change):
	#current_count = amount_to_change
	print(amount_to_change)
	counter_label.text = str(amount_to_change)
