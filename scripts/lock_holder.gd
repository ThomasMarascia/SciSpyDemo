extends Node2D

signal remove_lock
signal check_goal

var lock_pieces = []
var width = 8
var height = 8
var lock = preload("res://Scenes/lock_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func _on_grid_make_lock(grid_position):
	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()
	var current = lock.instantiate()
	add_child(current)
	current.position = Vector2(grid_position.x * 70 + 80, -grid_position.y * 70 + 750)
	lock_pieces[grid_position.x][grid_position.y] = current


func _on_grid_damage_lock(grid_position):
	if lock_pieces[grid_position.x][grid_position.y] != null:
		lock_pieces[grid_position.x][grid_position.y].take_damage(1)
		if lock_pieces[grid_position.x][grid_position.y].health <= 0:
			#check if lock piece is a type of goal
			emit_signal("check_goal", "lock")
			lock_pieces[grid_position.x][grid_position.y].queue_free()
			lock_pieces[grid_position.x][grid_position.y] = null
			emit_signal("remove_lock", grid_position)
