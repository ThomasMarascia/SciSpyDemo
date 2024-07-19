extends Node2D

signal remove_safe
signal check_goal

var safe_pieces = []
var width = 8
var height = 8
var safe = preload("res://Scenes/safe_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if safe_pieces.size() == 0:
		safe_pieces = make_2d_array()

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func _on_grid_make_safe(grid_position):
	if safe_pieces.size() == 0:
		safe_pieces = make_2d_array()
	var current = safe.instantiate()
	add_child(current)
	current.position = Vector2(grid_position.x * 70 + 80, -grid_position.y * 70 + 750)
	safe_pieces[grid_position.x][grid_position.y] = current


func _on_grid_damage_safe(grid_position):
	if safe_pieces[grid_position.x][grid_position.y] != null:
		safe_pieces[grid_position.x][grid_position.y].take_damage(1)
		if safe_pieces[grid_position.x][grid_position.y].health <= 0:
			#check if safe piece is a type of goal
			emit_signal("check_goal", "safe")
			safe_pieces[grid_position.x][grid_position.y].queue_free()
			safe_pieces[grid_position.x][grid_position.y] = null
			emit_signal("remove_safe", grid_position)
