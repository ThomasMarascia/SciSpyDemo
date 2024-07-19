extends Node2D

signal check_goal

var bars_pieces = []
var width = 8
var height = 8
var bars = preload("res://Scenes/bars_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if bars_pieces.size() == 0:
		bars_pieces = make_2d_array()

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func _on_grid_make_bars(grid_position):
	if bars_pieces.size() == 0:
		bars_pieces = make_2d_array()
	var current = bars.instantiate()
	add_child(current)
	current.position = Vector2(grid_position.x * 70 + 80, -grid_position.y * 70 + 750)
	bars_pieces[grid_position.x][grid_position.y] = current


func _on_grid_damage_bars(grid_position):
	if bars_pieces[grid_position.x][grid_position.y] != null:
		bars_pieces[grid_position.x][grid_position.y].take_damage(1)
		if bars_pieces[grid_position.x][grid_position.y].health <= 0:
			#check if bars piece is a type of goal
			emit_signal("check_goal", "bars")
			bars_pieces[grid_position.x][grid_position.y].queue_free()
			bars_pieces[grid_position.x][grid_position.y] = null
