extends Node2D

#State Variables
enum{wait, move, booster};
var state;

#this variable stored the id of the avatar the user selects (stored in config file)
var avatar = ConfigManager.avatar

#keeps track of how many times a special piece has been created (should only be created once per level)
var count = 0

#Swap Back Variables
var piece_one = null
var piece_two = null
var piece_three = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false

#Bomb/Booster Variables
var bomb_active = false #keeps track of if a bomb has been activated, housekeeping var for now but may be more useful in future
var click = false

''' Grid variables: 
	@export allows us to edit the values of variables in the editor.
	To do this, click the Object (scene) that has one of these variables, 
	then on the top of the right side in the inspector part you can see
	the variables you can change.
	(example: grid node within the GameWindow Scene has all the following 
	variables and all piece objects have the color variable)
'''
# Holds how many pieces will spawn in a row/column
@export var width: int
@export var height: int 

# Where will the pieces begin spawning on the x/y axis
@export var x_start: int 
@export var y_start: int 

# How far away each pieces will be from one another
@export var offset: int

@export var y_offset: int
@export var levelNum: int

# Obstacle related objects that appear on the level
@export var empty_spaces: PackedVector2Array
@export var bars_spaces: PackedVector2Array
@export var lock_spaces: PackedVector2Array
@export var safe_spaces: PackedVector2Array

# Obstacle related signals
signal make_bars
signal damage_bars
signal make_lock
signal damage_lock
signal make_safe
signal damage_safe

# Array of all piece objects (makes it easier to get a random piece when we spawn them)
var piece_options = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/brown_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/black_piece.tscn")
];

var colors = ['blue', 'red', 'green', 'brown', 'black']
# Array of the pieces to be seen on the screen

var all_pieces = []
var clone_array = []
var current_matches = []

# Variables to hold user touch input
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

# Game over state Variables
signal game_over

#Goal Check
signal check_goal

# Scoring variables
signal update_score
@export var piece_val: int
var streak = 1

# Count variables
signal update_counter
@export var current_counter_value: int

#Booster stuff
var booster_type

# sound variables
signal play_sound

'''
	func _ready comes with every script you make and it runs when the object enters the scene 
	(basically a main function of the object (constructor I guess?)
'''
func _ready():
	#initialize state variable
	state = move;
	# make the all_pieces array a 2d array and spawn the pieces in it
	all_pieces = make_2d_array()
	clone_array = make_2d_array()
	if(levelNum == 0):
		piece_spawner_equal(); #Spawns pieces completely randomly
	else:
		piece_spawner_weighted() #Spawns pieces according to their weight
		
	bars_spawner()
	lock_spawner()
	safe_spawner()
	# sets the counter variable
	emit_signal("update_counter", current_counter_value)

'''
	Checks whether any obstacles are on a space that restricts whether
	a space can be filled or not
'''
func restricted_fill(place):
	#Check the empty spaces
	if is_in_array(empty_spaces, place):
		return true
	if is_in_array(safe_spaces, place):
		return true
	return false
	
'''
	Returns whether a piece in the given space on the board should be able 
	to be moved
'''
func restricted_move(place):
	#Check the lock pieces
	if is_in_array(lock_spaces, place):
		return true
	return false
			
'''
	Checks if an item is in the array passed (used to check for obstacles)
'''
func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false
	
'''
	Removes a given item from the given array
'''
func remove_from_array(array, item):
	for i in range(array.size()-1, -1, -1):
		if array[i] == item:
			array.remove_at(i)
			
'''
	Makes the weight array based on the piece nodes' weight attributes
	(can also manually change weights here!)
'''
func get_weighted_array() -> Array:
	'''
		Piece order is [blue, brown, green, red, black]
	'''
	var weights_array: Array
	if(levelNum == 1):
		weights_array = [1,0,1,1,2] # [1,0,1,1,2] cooresponds to no brown pieces and twice the black pieces
	'''
	# could later do something like this to change spawn rates for each individual level:
	if(levelNum == 1):
		weights_array = [1,1,5,1,1]
	elif(levelNum == 2):
		weights_array = [2,4,2,1,0]
	elif(levelNum == 3):
		weights_array = [1,1,0.5,2,5]
		
	etc...
	
	'''
	if(weights_array.size() == 0):
		for i in range(piece_options.size()):
			var piece = piece_options[i].instantiate()
			weights_array.append(piece.weight)
		return weights_array
	else:
		for i in range(piece_options.size()):
			var piece = piece_options[i].instantiate()
			piece.weight = weights_array[i]
		return weights_array
	
'''
	This function makes a 1d array a 2d array full of nulls because godot doesn't have the
	c++ ability to make a 2d array by just doing int array[][].
'''
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
'''
	Loads in all the bars pieces set for the level
'''
func bars_spawner():
	for i in bars_spaces.size():
		emit_signal("make_bars", bars_spaces[i])

'''
	Loads in all the lock pieces set for the level
'''	
func lock_spawner():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])

'''
	Loads in all the safe pieces set for the level
'''	
func safe_spawner():
	for i in safe_spaces.size():
		emit_signal("make_safe", safe_spaces[i])

'''
	This function iterates through the grid and spawns random pieces in each spot (no weights)
'''
func piece_spawner_equal():
	for i in width:
		for j in height:
			#Check for obstacles on spaces
			if !restricted_fill(Vector2(i,j)):
				var rand = floor(randi_range(0, piece_options.size()-1))
				var piece = piece_options[rand].instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(randi_range(0, piece_options.size() - 1))
					loops += 1
					piece = piece_options[rand].instantiate()
				
				add_child(piece)
				piece.set_position(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	if is_deadlocked():

		await get_tree().create_timer(1.0).timeout

		shuffle_board()

'''
	I LOVE WEIGHTS!!!!
	Iterates through and calls weighted choice until there isn't a
	starting match on the grid
'''
func piece_spawner_weighted():
	var weights_array = get_weighted_array()
	for i in width:
		for j in height:
			#Check for obstacles on spaces
			if !restricted_fill(Vector2(i,j)):
				var piece = weighted_choice(piece_options, weights_array).instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					piece = weighted_choice(piece_options, weights_array).instantiate()
					loops += 1
				
				add_child(piece)
				piece.set_position(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
				$HintTimer.start()
	if is_deadlocked():

		await get_tree().create_timer(1.0).timeout

		shuffle_board()
'''
	the godot equivialent of the python command: random.choices(array, weights_array)
	sums and then normalizes the weights and then randomly chooses between them
'''
func weighted_choice(array: Array, weights: Array):
	var sum:float = 0.0
	for val in weights:
		sum += val
	var normalizedWeights = []
	for val in weights:
		normalizedWeights.append(val / sum)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rnd = rng.randf()
	var i = 0
	var test:float = 0.0
	for val in normalizedWeights:
		test += val
		if test >= rnd:
			return array[i]
		i += 1

'''
	Variables holding the effects after the block is destroyed
'''

var animated_explosion = preload("res://Scenes/Effects/animated_explosion.tscn")
var animated_explosion2 = preload("res://Scenes/Effects/animated_explosion2.tscn")
var bomb_animated_explosion = preload("res://Scenes/Effects/bomb_animated_explosion.tscn")
var combo_bomb_animated_explosion = preload("res://Scenes/Effects/combo_bomb_animated_explosion.tscn")
var animated_row_laser = preload("res://Scenes/Effects/row_animated_laser.tscn")
var animated_col_laser = preload("res://Scenes/Effects/column_animated_laser.tscn")
var red_explosion = preload("res://Scenes/Effects/red_explosion.tscn")
var coffee_spill = preload("res://Scenes/Effects/coffee_spill.tscn")
var coffee_drop = preload("res://Scenes/Effects/coffee_drop.tscn")
var animated_cop_car = preload("res://Scenes/Effects/animated_cop_car.tscn")

'''
hint effects
'''
var hint_effect = preload("res://Scenes/Effects/Hint_effect.tscn")
var hint = null
var match_color = ""

''' 
This function chooses which of the boosters on the buttonUI is selected
'''
var current_booster_type = "" 

'''
	This function checks if there is a match while the board is being created
'''
func match_at(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true;
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-2].color == color && all_pieces[i][j-2].color == color:
				return true;
	#square match (top)

	if i > 1 and j > 1 and all_pieces[i-1][j-1] != null and all_pieces[i-1][j] != null and all_pieces[i][j-1] != null:
		if all_pieces[i-1][j-1].color == color and all_pieces[i-1][j].color == color and all_pieces[i][j-1].color == color:
			return true
	# Square match (bottom)
	if i < len(all_pieces) - 2 and j > 1 and all_pieces[i+1][j-1] != null and all_pieces[i+1][j] != null and all_pieces[i][j-1] != null:
		if all_pieces[i+1][j-1].color == color and all_pieces[i+1][j].color == color and all_pieces[i][j-1].color == color:
			return true
	# Square match (left)
	if i > 1 and j > 1 and all_pieces[i-1][j-1] != null and all_pieces[i][j-1] != null and all_pieces[i-1][j] != null:
		if all_pieces[i-1][j-1].color == color and all_pieces[i][j-1].color == color and all_pieces[i-1][j].color == color:
			return true
	# Square match (right)
	if i > 1 and j < len(all_pieces[0]) - 2 and all_pieces[i-1][j+1] != null and all_pieces[i][j+1] != null and all_pieces[i-1][j] != null:
		if all_pieces[i-1][j+1].color == color and all_pieces[i][j+1].color == color and all_pieces[i-1][j].color == color:
			return true

	return false
'''
	This function converts a piece's spot in an array (so like row 2, column 4) to the pixel it should
	spawn based on the offset (how far away each piece is) and where the pieces started spawning 
	for y it is -offset because for some reason godot negative y values is up and positive is down (idk)
'''
func grid_to_pixel(column, row):
	var newX = column * offset + x_start
	var newY = row * -offset + y_start
	return Vector2(newX, newY)
'''
	The function basically gets called any time a frame happens, so since you want touch_input to happen all the time,
	it goes in this function
'''
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#only recognize touch inputs if the state is set to move
	if state == move:
		touch_input()
	elif state == booster:
		booster_input()
'''
	This is a helper function that does the opposite of the grid_to_pixel function
'''

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start)/ offset) 
	var new_y = round((pixel_y - y_start)/ -offset)
	return Vector2(new_x, new_y)
	
'''
	This function checks that the user is clicking in the grid to make sure they are not outside
	the bounds of the game
'''
func is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false
	
func is_in_grid_vector(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true;
	return false;
	
'''
	This function stores the user touch input into the first_touch and last_touch variables
'''
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var grid_position = pixel_to_grid(first_touch.x, first_touch.y)
		if is_in_grid(grid_position.x, grid_position.y): #makes sure when the touch first happens that its in the grid
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_global_mouse_position()
		var grid_position = pixel_to_grid(final_touch.x, final_touch.y)
		if !is_in_grid(grid_position.x, grid_position.y): #makes sure when touch ends that the touch is still in the grid
			controlling = false
		if is_in_grid(grid_position.x, grid_position.y) && controlling: #if both touches were in grid, then the swap can happen
			touch_difference(pixel_to_grid(first_touch.x, first_touch.y), grid_position)
		controlling = false #this prevevnts swapping of nodes outside of the board
		
	pass

'''
	This function performs the actual swapping of the pieces. Minimal Animation now included
	takes in column, row, and direction to be able to swap
	This function also performs part of swap backs
	This function now also plays part in bomb activation (deviation from tutorials), if a user 
	makes a swap that does not create a match but one of the pieces is a bomb then the bomb will
	activate then return the board to a move state
'''		
func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row];
	var second_piece = all_pieces[column+direction.x][row+direction.y];
	if first_piece != null && second_piece != null:
		#store current pieces and positions for if swap back is needed
		store_info(first_piece, second_piece, Vector2(column, row), direction)
		#set state to wait if pieces are swappable, we don't want the user to be able to swap other pieces
				# while the first two are still in the process of swapping
		state = wait;
		all_pieces[column][row] = second_piece;
		all_pieces[column+direction.x][row+direction.y] = first_piece;
		first_piece.move(grid_to_pixel(column+direction.x, row+direction.y));
		second_piece.move(grid_to_pixel(column, row));
		
	
		#if either piece is a bomb, the bomb will activate and destroy surrounding pieces
		check_combo(first_piece, second_piece, column, row, column+direction.x, row+direction.y)
			
		#check for matches after swap
		#if there are no matches, swap the pieces back to their original position
		#if there are no matches on unchecked moves, set timer to swap the pieces back to their original position

		if !move_checked && !find_matches():
			get_parent().get_node("swap_back_timer").start()
		
			
		if find_matches(): # if it is a match
		# current counter stuff
			current_counter_value -= 1
			emit_signal("update_counter", current_counter_value)
			if(current_counter_value == 0):
				declare_game_over()

	$HintTimer.start()

'''
	This function stores swap information so that pieces can be swapped back if they do
	not create a match	
'''
func store_info(first_piece, second_piece, place, direction):
	piece_one = first_piece
	piece_two = second_piece
	last_place = place
	last_direction = direction

'''
	This function swaps pieces back to their original position and then resets swap 
	info to null
'''
func swap_back():
	if piece_one != null && piece_two != null:
		#set move_checked to true so the swap_pieces function knows not to check this
			#swap for a match again
		move_checked = true;
		swap_pieces(last_place.x, last_place.y, last_direction)
	
	#reset variables
	state = move
	move_checked = false;
	piece_one = null
	piece_two = null
	last_place = Vector2(0, 0)
	last_direction = Vector2(0, 0)
	
	
	
'''
	This function calculates the difference between the two pieces and what the
	direction is based on if the difference is on the x or y axis and if its positive or negative
	
	*** Deviation from tutorial: if there is no difference in the two pieces' coordinates, it will 
	register as a click and can be used to activate a bomb on the board
'''
func touch_difference(grid1, grid2):
	var difference = grid2 - grid1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid1.x, grid1.y, Vector2(1,0)) #swaps right
		elif difference.x < 0:
			swap_pieces(grid1.x, grid1.y, Vector2(-1,0)) #swaps lil;]lt
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid1.x, grid1.y, Vector2(0,1)) #swaps up
		elif difference.y < 0:
			swap_pieces(grid1.x, grid1.y, Vector2(0,-1)) #swaps down
	elif abs(difference.x) == abs(difference.y):
		swap_pieces(grid1.x, grid1.y, Vector2(0, 0)) #click

'''
	Helper function to check square matches	
'''
func check_square(c, r, c1, r1, c2, r2, c3, r3, color, query, array = all_pieces):
	if !is_piece_null(c1, r1, array) && !is_piece_null(c2, r2, array) && !is_piece_null(c3, r3, array):
		if is_piece_color(c1, r1, color, array) && is_piece_color(c2, r2, color, array) && is_piece_color(c3, r3, color, array):
			
			if query:
				return true
			#dim color of pieces if they match
			match_and_dim(array[c][r])
			match_and_dim(array[c1][r1])
			match_and_dim(array[c2][r2])
			match_and_dim(array[c3][r3])
			add_to_array(Vector2(c, r))
			add_to_array(Vector2(c1, r1))
			add_to_array(Vector2(c2, r2))
			add_to_array(Vector2(c3, r3))
			#a match has been found

			return true;
	return false

'''
	This function detects vertical and horizontal matches by comparing
	pieces to ones directly beside/above/below them to see if they are 
	the same color
	we may want to alter it to include square matches, but for now it 
	recognizes 'line' matches and 'T'/'L' matches
'''	
func find_matches(query = false, array = all_pieces):
	#initialze match_found to false because we do not know if there is a match yet
	var match_found = false;
	#checks the entire grid for matches
	for i in width:
		for j in height:
			if array[i][j] != null:
				#set current_color to the color of the given piece
				var current_color = array[i][j].color;
				if current_color != "bomb":
					#horizontal match
					if i > 0 && i < width - 1:
						if !is_piece_null(i-1, j, array) && !is_piece_null(i+1, j, array):
							if is_piece_color(i-1, j, current_color, array) && is_piece_color(i+1, j, current_color, array):
								if query:
									return true
								#dim color of pieces if they match
								match_and_dim(array[i-1][j])
								match_and_dim(array[i][j])
								match_and_dim(array[i+1][j])
								add_to_array(Vector2(i, j))
								add_to_array(Vector2(i + 1, j))
								add_to_array(Vector2(i - 1, j))
								#a match has been found
								match_found = true;
					#vertical match
					if j > 0 && j < height - 1:
						if !is_piece_null(i, j-1, array) && !is_piece_null(i, j+1, array):
							if is_piece_color(i, j-1, current_color, array) && is_piece_color(i, j+1, current_color, array):
								if query:
									return true
								#dim color of pieces if they match
								match_and_dim(array[i][j-1])
								match_and_dim(array[i][j])
								match_and_dim(array[i][j+1])
								add_to_array(Vector2(i, j))
								add_to_array(Vector2(i, j + 1))
								add_to_array(Vector2(i, j - 1))
								#a match has been found
								match_found = true;
#								destroy_hint()
					#square matches
					if j > 0 && j < height - 1 && i > 0 && i < width - 1:
						if check_square(i, j, i, j-1, i-1, j, i-1, j-1, current_color, query, array):
							match_found = true
						if check_square(i, j, i, j+1, i+1, j, i+1, j+1, current_color, query, array):
							match_found = true
						if check_square(i, j, i-1, j, i, j+1, i-1, j+1, current_color, query, array):
							match_found = true
						if check_square(i, j, i, j-1, i+1, j, i+1, j-1, current_color, query, array):
							match_found = true
	if query:
		return false
	move_checked = true;
	#start the destroy timer to destroy the matched
	if match_found || !find_bombs():
		get_parent().get_node("destroy_timer").start();
	return match_found;
'''
	Checks whether piece at given coordinates is null
'''
func is_piece_null(column, row, array = all_pieces):
	if array[column][row] == null:
		return true
	return false
'''
	Checks whether piece at given coordinates matches the given color
'''
func is_piece_color(column, row, color, array = all_pieces):
	if array[column][row].color == color:
		return true
	return false
'''
	Sets the item's matched value to true and dims the item
'''
func match_and_dim(item):
	item.matched = true
	item.dim()

'''
	This function checks if swapped pieces are bombs. If both pieces are bombs then a combo move is created
'''
func check_combo(piece_one, piece_two, column_one, row_one, column_two, row_two):
	var activate_bomb = false
	#check that both pieces are bombs and that they aren't the same piece
	if piece_one.is_bomb && piece_two.is_bomb && piece_one != piece_two:
		#if both pieces are color bombs, clear the board
		if piece_one.is_color_bomb && piece_two.is_color_bomb:
			clear_board()
		
		#if one piece is adjacent bomb and one is color bomb, set piece one as an adj_color combo and deactivate piece two
		if piece_one.is_color_bomb && piece_two.is_adjacent_bomb || piece_one.is_adjacent_bomb && piece_two.is_color_bomb:
			piece_one.is_adj_color = true
			piece_one.is_adjacent_bomb = true
			piece_one.is_color_bomb = false
			piece_two.is_adjacent_bomb = false
			piece_two.is_color_bomb = false
		#color x column
		elif piece_one.is_color_bomb && piece_two.is_column_bomb || piece_one.is_column_bomb && piece_two.is_color_bomb:
			piece_one.is_col_color = true
			piece_one.is_column_bomb = true
			piece_one.is_color_bomb = false
			piece_two.is_column_bomb = false
			piece_two.is_color_bomb = false
		#color x row
		elif piece_one.is_color_bomb && piece_two.is_row_bomb || piece_one.is_row_bomb && piece_two.is_color_bomb:
			piece_one.is_row_color = true
			piece_one.is_row_bomb = true
			piece_one.is_color_bomb = false
			piece_two.is_row_bomb = false
			piece_two.is_color_bomb = false
			piece_two.matched = true
		#color x square combo
		elif piece_one.is_color_bomb && piece_two.is_square_bomb || piece_one.is_square_bomb && piece_two.is_color_bomb:
			piece_one.is_square_color = true
			piece_one.is_square_bomb = true
			piece_one.is_color_bomb = false
			piece_two.is_square_bomb = false
			piece_two.is_color_bomb = false
			piece_two.matched = true
		
		#adjacent combos (excluding color)
		elif piece_one.is_adjacent_bomb or piece_two.is_adjacent_bomb:
			#if combined with row/column bomb, set x_combo for piece one and deactivate piece two
			if piece_one.is_row_bomb or piece_one.is_column_bomb or piece_two.is_row_bomb or piece_two.is_column_bomb:
				piece_one.is_row_bomb = false
				piece_two.is_row_bomb = false
				piece_one.is_column_bomb = false
				piece_two.is_column_bomb = false
				piece_one.is_x_combo = true
			#if combine3d with adjacent, set adj_combo
			elif piece_one.is_adjacent_bomb && piece_two.is_adjacent_bomb:
				piece_one.is_adj_combo = true
			
			piece_one.is_adjacent_bomb = false
			piece_two.is_adjacent_bomb = false
		#row x column, row x row, column x column combo sets row_col combo on piece one and deactivates piece two
		elif piece_one.is_row_bomb or piece_one.is_column_bomb or piece_two.is_row_bomb or piece_two.is_column_bomb:
			piece_one.is_row_bomb = false
			piece_one.is_column_bomb = false
			piece_two.is_row_bomb = false
			piece_two.is_column_bomb = false
			piece_one.is_row_col_combo = true
		
		#start the bombs
		all_pieces[column_two][row_two].matched = true
		get_bombed_pieces()
		move_checked = true
		activate_bomb = true
	
	#if only piece one is a bomb
	elif piece_one.is_bomb:
		#if it is a color bomb then set piece one color to the color of the piece it was swapped with
		if piece_one.is_color_bomb:
			piece_one.color = piece_two.color
		#start the bomb
		all_pieces[column_two][row_two].matched = true
		get_bombed_pieces()
		move_checked = true
		activate_bomb = true
	elif piece_two.is_bomb:
		if piece_two.is_color_bomb:
			piece_two.color = piece_one.color
		all_pieces[column_one][row_one].matched = true
			#call this function to set the column, row, or adjacent pieces to the bomb to matched so they get destroyed
		get_bombed_pieces()
		move_checked = true
		activate_bomb = true
	return activate_bomb



'''
	This function will find pieces that need to be destroyed when a bomb is activated
	Due to the differences between our planned gameplay and that of the tutorial, this
		will need to be modified so that the user can click or move the bomb to activate
'''
func get_bombed_pieces():

	bomb_active = true
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched == true:
					#if a piece is set with a row columb combo, it will destroy an entire row and an entire combo
					if all_pieces[i][j].is_row_col_combo:
						match_all_in_col(i)
						match_all_in_row(j)
					#if a piece is set with adj combo, it will destroy a 4x4 area of pieces
					elif all_pieces[i][j].is_adj_combo:
						match_all_adjacent_combo(i, j)
					#if a piece is set with x combo, it will destroy 3 rows and 3 columns
					elif all_pieces[i][j].is_x_combo:
						match_all_in_row(j-1)
						match_all_in_row(j)
						match_all_in_row(j+1)
						match_all_in_col(i-1)
						match_all_in_col(i)
						match_all_in_col(i+1)
					#if a piece is set as adj_color, it will replace all pieces of a random color with adjacent bombs
					elif all_pieces[i][j].is_adj_color:
						replace_all_color(colors[randi_range(0, colors.size()-1)], 0)
					#if a piece is set as col_color, it will replace all pieces of a random color with column bombs
					elif all_pieces[i][j].is_col_color:
						replace_all_color(colors[randi_range(0, colors.size()-1)], 1)
					#if a piece is set as row_color, it will replace all pieces of a random color with row bombs
					elif all_pieces[i][j].is_row_color:
						replace_all_color(colors[randi_range(0, colors.size()-1)], 2)
					#if a piece is set as square_color, it will replace all pieces of a random color with square bombs
					elif all_pieces[i][j].is_square_color:
						replace_all_color(colors[randi_range(0, colors.size()-1)], 4)
					#if a piece is a square bomb, it will destroy the pieces immediately touching it as well as one random piece on the grid
					elif all_pieces[i][j].is_square_bomb:
						match_by_square(i, j)
					#column bomb destroys an entire column
					elif all_pieces[i][j].is_column_bomb:
						match_all_in_col(i)
					#row bomb destroys an entire row
					elif all_pieces[i][j].is_row_bomb:
						#if the row bomb is a special avatar piece then it will also destroy either the row above or below
						if all_pieces[i][j].special_piece:
							if is_in_grid(i,j-1):
								all_pieces[i][j-1].is_row_bomb = true
								all_pieces[i][j-1].special_piece = true
								match_all_in_row(j-1)
							elif is_in_grid(i,j+1):
								all_pieces[i][j+1].is_row_bomb = true
								all_pieces[i][j+1].special_piece = true
								match_all_in_row(j+1)
						else: 
							match_all_in_row(j)
					#if the piece is an adjacent bomb it will destroy a 3x3 area of pieces
					elif all_pieces[i][j].is_adjacent_bomb:
						#if it is a special avatar piece, it will destroy a 4x4 area
						if all_pieces[i][j].special_piece:
							all_pieces[i][j].is_adj_combo = true
							match_all_adjacent_combo(i, j)
						else:
							match_all_adjacent(i, j)
					#if the piece is a color bomb
					elif all_pieces[i][j].is_color_bomb:
						var color_used = ''
						#if the piece has been swapped to activate then it will destroy the color of the piece it was swapped with
						if all_pieces[i][j].color != "bomb":
							match_all_color(all_pieces[i][j].color)
							color_used = all_pieces[i][j].color
						#if the piece was clicked to activate then it will destroy a random color on the grid
						else:
							color_used = colors[randi_range(0, colors.size()-1)]
							match_all_color(color_used)
						#if the piece was a special avatar piece then it will destroy an additional random color that hasn't been used yet
						if all_pieces[i][j].special_piece:
							var color_choices = []
							for item in colors:
								if item != color_used:
									color_choices.append(item)
							match_all_color(color_choices[randi_range(0, color_choices.size()-1)])
	get_parent().get_node("destroy_timer").start();
	current_counter_value -= 1
	emit_signal("update_counter", current_counter_value)
	if(current_counter_value == 0):
		declare_game_over()

'''
	This function adds matched pieces to an array to keep track of all currently matched pieces
'''
func add_to_array(value, array_to_add = current_matches):
	if !array_to_add.has(value):
		array_to_add.append(value)
		
'''
	This function iterates over the array of current matches to find patterns that should be turned into bombs
'''	
func find_bombs():

	var bomb_found = false
	#iterate over current_matches array
	for i in current_matches.size():
		#store vals for match
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		var current_color = all_pieces[current_column][current_row].color
		var col_matched = 0
		var row_matched = 0
		#iterate over current matches to check for col, row, color
		for j in current_matches.size():
			var this_column = current_matches[j].x
			var this_row = current_matches[j].y
			var this_color = all_pieces[this_column][this_row].color
			if this_column == current_column and current_color == this_color:
				col_matched += 1
			if this_row == current_row and this_color == current_color:
				row_matched += 1
		#5 pieces in a column/row match make a color bomb (if avatar is Bree then special colored flask)
		if col_matched == 5 or row_matched == 5:
			if count < 1 && avatar == 0:
				count = count + 1
				make_bomb(7, current_color)
			else:
				make_bomb(3, current_color)
			bomb_found = true
			return bomb_found
		#more than 3 pieces in a column/row makes an adjacent bomb (if avatar is Matthew then grenade)
		elif col_matched >= 3 and row_matched >= 3:
			if count < 1 && avatar == 1:
				count = count + 1
				make_bomb(5, current_color)
			else:
				make_bomb(0, current_color)
			bomb_found = true
			return bomb_found
			#4 pieces in a column mnake a column bomb
		elif col_matched == 4:
			make_bomb(1, current_color)
			bomb_found = true
			return bomb_found
			#4 pieces in a row make a row bomb (if avatar is James then crosshairs)
		elif row_matched == 4:
			if count < 1 && avatar == 2:
				count = count + 1
				make_bomb(6, current_color)
			else:
				make_bomb(2, current_color)
			bomb_found = true
			return bomb_found
		#if the column and row are greater than or equal to 2 and don't meet other conditions then a square bomb is made
		elif col_matched >= 2 and row_matched >= 2:
			make_bomb(4, current_color)
			bomb_found = true
			return bomb_found
	return bomb_found



'''
	This function will check which piece should be turned into a bomb and changes it into a bomb
'''			
func make_bomb(bomb_type, color):
	#iterate over current matches
	for i in current_matches.size():
		#cache variables
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		#check to see which of the swapped pieces created the bomb match
		if all_pieces[current_column][current_row] == piece_one and piece_one.color == color:
			#set the piece to unmatched so it doesn't get destroyed
			piece_one.matched = false
			#if it is a normal bomb, set the piece color to bomb so that it does not make an unintentional match and disappear
			piece_one.color = "bomb"
			#change the appearance of the piece to be a bomb
			change_bomb(bomb_type, piece_one)
			return
		if all_pieces[current_column][current_row] == piece_two and piece_two.color == color:
			piece_two.matched = false
			piece_two.color = "bomb"
			change_bomb(bomb_type, piece_two)
			return
		if all_pieces[current_column][current_row] == piece_three and piece_three.color == color:
			#set the piece to unmatched so it doesn't get destroyed
			piece_three.matched = false
			#if it is a normal bomb, set the piece color to bomb so that it does not make an unintentional match and disappear
			piece_three.color = "bomb"
			#change the appearance of the piece to be a bomb
			change_bomb(bomb_type, piece_three)
			return

			

'''
	This function will trigger a piece to be changed into a bomb based on how it
	is matched; calls piece functions from piece.gd
'''			
func change_bomb(bomb_type, piece):
	if bomb_type == 0:
		piece.make_adjacent_bomb()
	elif bomb_type == 1:
		piece.make_column_bomb()
	elif bomb_type == 2:
		piece.make_row_bomb()
	elif bomb_type == 3:
		piece.make_color_bomb()
	elif bomb_type == 4:
		piece.make_square_bomb()
	elif bomb_type == 5:
		piece.make_adjacent_bomb(avatar)
	elif bomb_type == 6:
		piece.make_row_bomb(avatar)
	elif bomb_type == 7:
		piece.make_color_bomb(avatar)

'''
	this function destroys matches by checking the grid for pieces marked as matched.
	if marked as matched, it frees them from the grid, marks them as null, and starts
	the collapse timer.
'''
func destroy_matched():
	find_bombs()
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					emit_signal("check_goal", all_pieces[i][j].color)
					var effect = null
					var effect2 = null
					#this variable is set to true if an effect needs to span multiple rows
					var multirow = false
					
					#default destruction
					if !all_pieces[i][j].path_of_bomb:
						effect = animated_explosion
					#adjacent bomb
					if all_pieces[i][j].is_adjacent_bomb:
						effect = bomb_animated_explosion
					#adjacent combo
					if all_pieces[i][j].is_adj_combo:
						effect = combo_bomb_animated_explosion
					#row and column combo has two effects
					if all_pieces[i][j].is_row_col_combo:
						effect = animated_row_laser
						effect2 = animated_col_laser
					#x combo (adjacent x row/column) has two effects that span multiple rows/columns
					if all_pieces[i][j].is_x_combo:
						effect = animated_row_laser
						effect2 = animated_col_laser
						multirow = true
					#row bomb can have different effect if it is a special piece
					if all_pieces[i][j].is_row_bomb:
						if all_pieces[i][j].special_piece:
							effect = red_explosion
						else:
							effect = animated_row_laser
					#column bomb
					if all_pieces[i][j].is_column_bomb:
						effect = animated_col_laser
					#square bomb has two separate effects
					if all_pieces[i][j].is_square_bomb:
						effect = coffee_spill
					if all_pieces[i][j].drop:
						effect2 = coffee_drop
					damage_special(i, j) #damage any special pieces on the space
					#remove destroyed pieces from grid
					all_pieces[i][j].queue_free();
					all_pieces[i][j] = null;
					#play the effects
					if effect != null:
						if state == wait:
							#row column combo, laser row effect must be set to the center column and column laser must be set to the center row
							if effect == animated_row_laser && effect2 == animated_col_laser && multirow == false:
								make_effect(effect, floor(float(width)/2), j)
								make_effect(effect2, i, floor(float(height)/2))
								await get_tree().create_timer(0.25).timeout
							#adjacent row/column combo
							elif effect == animated_row_laser && effect2 == animated_col_laser && multirow == true:
								make_effect(effect, floor(float(width)/2), j-1)
								make_effect(effect2, i-1, floor(float(height)/2))
								make_effect(effect, floor(float(width)/2), j)
								make_effect(effect2, i, floor(float(height)/2))
								make_effect(effect, floor(float(width)/2), j+1)
								make_effect(effect2, i+1, floor(float(height)/2))
								await get_tree().create_timer(0.25).timeout
							elif effect == animated_row_laser:
								make_effect(effect, floor(float(width)/2), j)
								await get_tree().create_timer(0.25).timeout
							elif effect == animated_col_laser:
								make_effect(effect, i, floor(float(height)/2))
							#special crosshairs effect. play the effect on each column of the row
							elif effect == red_explosion:
								for w in width:
									make_effect(effect, w, j)
							#default effect
							else:
								make_effect(effect, i, j)
					#make_effect(animated_explosion2, i, j)
					#make_effect(bomb_animated_explosion, i, j)
					emit_signal("play_sound")
					emit_signal("update_score", piece_val*streak)
					#signal to collapse the columns where pieces were destroyed
					get_parent().get_node("collapse_timer").start();
	current_matches.clear()
	
func check_safe(column, row):
	#Check right side
	if column < width - 1:
		emit_signal("damage_safe", Vector2(column + 1, row))
	#check left side
	if column > 0:
		emit_signal("damage_safe", Vector2(column - 1, row))
	#Check up side
	if row < height - 1:
		emit_signal("damage_safe", Vector2(column, row + 1))
	#Check down side
	if row > 0:
		emit_signal("damage_safe", Vector2(column, row - 1))

'''
	Calls each different function to damage any unique pieces over a space
'''
func damage_special(column, row):
	emit_signal("damage_bars", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))
	check_safe(column, row)	

func make_effect(effect, column, row):
	var current = effect.instantiate()
	current.position = grid_to_pixel(column, row)
	add_child(current)

'''
	this function collapses columns after matches are destroyed by checking for null spaces
	in the grid. it then checks from the height of the null space to the top of the grid for
	non-null pieces. if there exists non-null pieces above, it moves them to the position of 
	the null pieces. then it starts the refill timer.
'''
func collapse_columns():
	for i in width:
		for j in height:
			#If the space is empty and it's not an intentionally empty space
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						#move the above pieces to the space of the deleted pieces
						all_pieces[i][k].move(grid_to_pixel(i, j));
						all_pieces[i][j] = all_pieces[i][k];
						#set the original position of the pieces that moved down to null, there are no pieces there now
						all_pieces[i][k] = null;
						break;
	#signal to refill the grid
	get_parent().get_node("refill_timer").start();
	pass;
	
'''
	this function refills the columns by looking for empty spaces on the board and
	using logic from the spawn pieces function to put random pieces in those spaces.
	then if commences an 'after_refill' sequence that checks for and matches that
	may have been formed in the process of refilling the empty spaces
	!!! the transitions for the piece respawn need to be tweaked, they are currently
	moving from a bottom position upwards, but they should probably drop from the top!!!
'''
func refill_columns_equal():
	streak += 1
	for i in width:
		for j in height:
			#If the space is empty and it's not an intentionally empty space
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i,j)):
				#logic from piece_spawner()
				var rand = floor(randi_range(0, piece_options.size()-1))
				var piece = piece_options[rand].instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(randi_range(0, piece_options.size() - 1))
					loops += 1
					piece = piece_options[rand].instantiate()
				
				add_child(piece)
				piece.set_position(grid_to_pixel(i,j + y_offset))
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	#check grid
	#find_bombs()
	var match_found = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				#check for matches
				if match_at(i, j, all_pieces[i][j].color):
					state = wait
					#temp piece variable to aid in bomb-ifying fallen matches
					piece_three = all_pieces[i][j]
					#check for fall matches and fall matches that can be turned into bombs
					if find_matches():
						match_found = true
					if find_bombs():
						match_found = true
	#if no matches are found from refilling the board, let the player move again
	if !match_found:
		move_checked = false
		state = move
	#check for deadlock, shuffle the board if it exists
	if is_deadlocked():
		await get_tree().create_timer(1.0).timeout
		shuffle_board()
	streak = 1
	
func refill_columns_weighted():
	var weights_array = get_weighted_array()
	for i in width:
		for j in height:
			#If the space is empty and it's not an intentionally empty space
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i,j)):
				var piece = weighted_choice(piece_options, weights_array).instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					piece = weighted_choice(piece_options, weights_array).instantiate()
					loops += 1
				
				add_child(piece)
				piece.set_position(grid_to_pixel(i,j + y_offset))
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	#check grid
	var match_found = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				#check for matches
				if match_at(i, j, all_pieces[i][j].color):
					state = wait
					#temp piece variable to aid in bomb-ifying fallen matches
					piece_three = all_pieces[i][j]
					#check for fall matches and fall matches that can be turned into bombs
					if find_matches():
						match_found = true
					if find_bombs():
						match_found = true
		
	if !match_found:
		move_checked = false
		state = move
	if is_deadlocked():
		await get_tree().create_timer(1.0).timeout
		shuffle_board()
	streak = 1
	
'''
	This function sets every piece in the grid to matched
'''
func clear_board():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				all_pieces[i][j].matched = true;
				all_pieces[i][j].dim();
				add_to_array(Vector2(i,j))
				
'''
	The following two helper functions will set an entire column or an
	entire row to matched
	They also chains any other bombs that are in its path
'''
func match_all_in_col(column):
	#iterate over each row in the column
	for i in height:
		#check that piece is in grid
		if is_in_grid_vector(Vector2(column, i)):
			if all_pieces[column][i] != null:
				#check for chaining bombs
				#if this piece in the bomb path is a row bomb, match all pieces in the current row
				if all_pieces[column][i].is_row_bomb:
					match_all_in_row(i)
				#if this piece in the bomb path is an adjacent bomb, match all pieces adjacent from the current piece
				if all_pieces[column][i].is_adjacent_bomb:
					match_all_adjacent(column, i)
				#if this piece in the bomb path is a color bomb, match all pieces of a set color
				if all_pieces[column][i].is_color_bomb:
					match_all_color(all_pieces[column][i].color)
				#set this piece to matched
				all_pieces[column][i].matched = true
				all_pieces[column][i].path_of_bomb = true
	
func match_all_in_row(row):
	#iterate over each column in the row
	for i in width:
		if is_in_grid_vector(Vector2(i, row)):
			if all_pieces[i][row] != null:
				if all_pieces[i][row].is_column_bomb:
					match_all_in_col(i)
				if all_pieces[i][row].is_adjacent_bomb:
					match_all_adjacent(i, row)
				if all_pieces[i][row].is_color_bomb:
					match_all_color(all_pieces[i][row].color)
				all_pieces[i][row].matched = true
				all_pieces[i][row].path_of_bomb = true
	
'''
	This helper function will set a square of surrounding pieces to matched
	It also chains any other bombs that are in its path
	*** need to test adajcent x color
'''		
func match_all_adjacent(column, row):
	#iterate over surrounding pieces
	for i in range(-1, 2):
		for j in range(-1, 2):
			if is_in_grid_vector(Vector2(column + i, row + j)):
				if all_pieces[column + i][row + j] != null:
					if all_pieces[column + i][row + j].is_row_bomb:
						match_all_in_row(j)
					if all_pieces[column + i][row + j].is_column_bomb:
						match_all_in_col(i)
					if all_pieces[column + i][row + j].is_color_bomb:
						match_all_color(all_pieces[column + i][row + j].color)
					all_pieces[column + i][row + j].matched = true;
					#set surrounding pieces as path_of_bomb to aid in animations
					if all_pieces[column][row].is_adjacent_bomb:
						all_pieces[column + i][row + j].path_of_bomb = true;
	
func match_all_adjacent_combo(column, row):
	#iterate over larger surrounding are of pieces
	for i in range(-2, 3):
		for j in range(-2, 3):
			if is_in_grid_vector(Vector2(column + i, row + j)):
				if all_pieces[column + i][row + j] != null:
					if all_pieces[column + i][row + j].is_row_bomb:
						match_all_in_row(j)
					if all_pieces[column + i][row + j].is_column_bomb:
						match_all_in_col(i)
					if all_pieces[column + i][row + j].is_color_bomb:
						match_all_color(all_pieces[column + i][row + j].color)
					all_pieces[column + i][row + j].matched = true;
					if all_pieces[column][row].is_adj_combo:
						all_pieces[column + i][row + j].path_of_bomb = true;
		
'''

	This helper function will match pieces immediately touching the original piece and one random piece

	in the grid

'''					

func match_by_square(column, row):
	if is_in_grid_vector(Vector2(column+1, row)):
		if all_pieces[column+1][row] != null:
			if all_pieces[column + 1][row].is_row_bomb:
				match_all_in_row(row)
			if all_pieces[column + 1][row].is_column_bomb:
				match_all_in_col(column + 1)
			if all_pieces[column + 1][row].is_color_bomb:
				match_all_color(all_pieces[column + 1][row].color)
			if all_pieces[column+1][row].is_adjacent_bomb:
				match_all_adjacent(column+1, row)
			all_pieces[column + 1][row].matched = true;
	if is_in_grid_vector(Vector2(column-1, row)):
		if all_pieces[column-1][row] != null:
			if all_pieces[column - 1][row].is_row_bomb:
				match_all_in_row(row)
			if all_pieces[column - 1][row].is_column_bomb:
				match_all_in_col(column - 1)
			if all_pieces[column - 1][row].is_color_bomb:
				match_all_color(all_pieces[column - 1][row].color)
			if all_pieces[column-1][row].is_adjacent_bomb:
				match_all_adjacent(column-1, row)
			all_pieces[column - 1][row].matched = true;
	if is_in_grid_vector(Vector2(column, row + 1)):
		if all_pieces[column][row + 1] != null:
			if all_pieces[column][row + 1].is_row_bomb:
				match_all_in_row(row + 1)
			if all_pieces[column][row + 1].is_column_bomb:
				match_all_in_col(column)
			if all_pieces[column][row + 1].is_color_bomb:
				match_all_color(all_pieces[column][row + 1].color)
			if all_pieces[column][row+1].is_adjacent_bomb:
				match_all_adjacent(column, row+1)
			all_pieces[column][row + 1].matched = true;
	if is_in_grid_vector(Vector2(column, row - 1)):
		if all_pieces[column][row - 1] != null:
			if all_pieces[column][row - 1].is_row_bomb:
				match_all_in_row(row - 1)
			if all_pieces[column][row - 1].is_column_bomb:
				match_all_in_col(column)
			if all_pieces[column][row - 1].is_color_bomb:
				match_all_color(all_pieces[column][row - 1].color)
			if all_pieces[column][row-1].is_adjacent_bomb:
				match_all_adjacent(column, row-1)
			all_pieces[column][row - 1].matched = true;
	#need to find a way to ensure that random destroyed piece is not one of the pieces already being destroyed
	var rand_width = randf_range(0, width)
	var rand_height = randf_range(0, height)
	if is_in_grid_vector(Vector2(rand_width, rand_height)):
		if all_pieces[rand_width][rand_height] != null:
			all_pieces[rand_width][rand_height].matched = true
			all_pieces[rand_width][rand_height].drop = true

'''
	This helper function will set all pieces of a specified color to matched
'''			
func match_all_color(color):
	for i in height:
		for j in width:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].color == color:
					all_pieces[i][j].swell()
					all_pieces[i][j].blink()
					all_pieces[i][j].matched = true

'''
	This helper function will replace all pieces of one color with a bomb and activate them
'''

func replace_all_color(color, bomb_type):
	for i in height:
		for j in width:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].color == color:
					#change all pieces of a color to bomb type that triggered combo and activate all of that type of bomb
					if bomb_type == 0:
						change_bomb(0, all_pieces[i][j])
						all_pieces[i][j].blink()
						all_pieces[i][j].matched = true
					if bomb_type == 1:
						change_bomb(1, all_pieces[i][j])
						all_pieces[i][j].blink()
						all_pieces[i][j].matched = true
					if bomb_type == 2:
						change_bomb(2, all_pieces[i][j])
						all_pieces[i][j].blink()
						all_pieces[i][j].matched = true
					if bomb_type == 3:
						change_bomb(3, all_pieces[i][j])
						all_pieces[i][j].blink()
						all_pieces[i][j].matched = true
				#makes sure that the piece that triggered the combo is destroyed
				elif all_pieces[i][j].is_adj_color || all_pieces[i][j].is_col_color || all_pieces[i][j].is_row_color:
					all_pieces[i][j].blink()
					all_pieces[i][j].matched = true

'''
Hint Effects
'''
func switch_pieces(place, direction, array):
	if is_in_grid_vector(place) and !restricted_fill(place):
		if is_in_grid_vector(place + direction) and !restricted_fill(place + direction):
			var holder = array[place.x + direction.x][place.y + direction.y]
			# Then set the swap spot as the original piece
			array[place.x + direction.x][place.y + direction.y] = array[place.x][place.y]
			# Then set the original spot as the other piece
			array[place.x][place.y] = holder
			
func is_deadlocked():
	#create a copy of all_pieces array
	clone_array = copy_array(all_pieces)
	for i in width:
		for j in height:
			#switch and check right
			#if clone_array[i][j].is_bomb:
				#return false
			if switch_and_check(Vector2(i, j), Vector2(1, 0), clone_array):
				return false
			#switch and check up
			if switch_and_check(Vector2(i, j), Vector2(0, 1), clone_array):
				return false
	return true
	

func switch_and_check(place, direction, array):
	switch_pieces(place, direction, array)
	if find_matches(true, array):
		destroy_hint()
		switch_pieces(place, direction, array)
		return true
	switch_pieces(place, direction, array)
	return false

func copy_array(array_to_copy):
	var new_array = make_2d_array()
	for i in width:
		for j in height:
			new_array[i][j] = array_to_copy[i][j]
	return new_array
	
func clear_and_store_board():
	var holder_array = []
	for i in width:
		for j in height:
			if !is_piece_null(i, j):
				holder_array.append(all_pieces[i][j])
				all_pieces[i][j] = null
	return holder_array

func find_all_matches():
	var hint_holder = []
	clone_array = copy_array(all_pieces)
	for i in width:
		for j in height:
			#add the piece i,j to the hint_holder
			if clone_array[i][j] != null:
				var piece_color = is_piece_color(i, j, clone_array[i][j].color)
				if switch_and_check(Vector2(i,j), Vector2(1, 0), clone_array) and is_in_grid_vector(Vector2(i + 1, j)):
						if piece_color == true:
							hint_holder.append({"piece": clone_array[i][j], "is_needed_piece": true})
						else:
							hint_holder.append({"piece": clone_array[i + 1][j], "is_needed_piece": true})
				if switch_and_check(Vector2(i,j), Vector2(0, 1), clone_array) and is_in_grid_vector(Vector2(i, j + 1)):
				#add the piece i,j to the hint_holder
					if piece_color != false:
						if piece_color == true:
							hint_holder.append({"piece": clone_array[i][j], "is_needed_piece": true})
						else: 
							hint_holder.append({"piece": clone_array[i][j + 1], "is_needed_piece": true})
					else:
						hint_holder.append({"piece": clone_array[i][j], "is_needed_piece": false})
	return hint_holder

	
func shuffle_board():
	var holder_array = clear_and_store_board()
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i,j)):
				var rand = floor(randi_range(0, holder_array.size()-1))
				var piece = holder_array[rand]
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(randi_range(0, holder_array.size()-1))
					loops += 1
					piece = holder_array[rand]
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
				holder_array.remove_at(rand)
	if is_deadlocked():
		await get_tree().create_timer(1.0).timeout
		shuffle_board()
	state = move

func generate_hint():
	var hints = find_all_matches()
	if hints != null:
		if hints.size() > 0:
			destroy_hint()
			var bestHintIndex = 0
			var bestScore = -1
			
			for i in range(hints.size()):
				hint = hints[i]
				var score = calculate_hint_score(hint)
				if score > bestScore:
					bestScore = score
					bestHintIndex = i
			
			var bestHint = hints[bestHintIndex]["piece"]
			
			hint = hint_effect.instantiate()
			add_child(hint)
			hint.position = bestHint.position
			hint.Setup(bestHint.get_node("Sprite2D").texture)

func calculate_hint_score(hinte):
	if hinte.is_needed_piece:
		return 100
	else:
		return 1

func destroy_hint():
	if hint:
		hint.queue_free()
		hint = null

'''
	this function dictates what happens after the destroy timer times out
	it destroys the matches, and (against the instruction of the video) it
	calls the collapse_columns and refill_columns functions (when these were
	not included in this timeout function, these commands would not take place
	until the player made their next move)
'''

func _on_destroy_timer_timeout():
	destroy_hint();
	destroy_matched();
	#collapse_columns(); #this is an addition to the tutorial code, 
						#without it the columns collapse after the 
						#next move instead of after a match is destroyed
	#if(levelNum == 0):
		#refill_columns_equal();	#same with refill
	#else:
		#refill_columns_weighted()

'''
	this function dictates what happens after the collapse timer times out.
	it collapses columns
'''
func _on_collapse_timer_timeout():
	collapse_columns();
	
'''
	this function dictates what happens after the refill timer times out.
	it refills columns
'''
func _on_refill_timer_timeout():
	bomb_active = false
	click = false
	if(levelNum == 0):
		refill_columns_equal();
	else:
		refill_columns_weighted()
		
func _on_swap_back_timer_timeout():
	swap_back()

func declare_game_over():
	emit_signal("game_over")
	state = wait
	
'''
	this function dictates what happens when the buyable boosters get called
'''

func booster_input():
	if Input.is_action_just_pressed("ui_touch"):
		if current_booster_type == "Flask Bomb":
			var temp = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			if is_in_grid(temp.x, temp.y):
				if all_pieces[temp.x][temp.y] !=null:
					all_pieces[temp.x][temp.y].is_color_bomb = true
					all_pieces[temp.x][temp.y].matched = true
					get_bombed_pieces()
					state = move
		elif current_booster_type == "Sniper Piece":
			var temp = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			if is_in_grid(temp.x, temp.y):
				if all_pieces[temp.x][temp.y] !=null:
					all_pieces[temp.x][temp.y].is_adjacent_bomb = true
					all_pieces[temp.x][temp.y].matched = true
					get_bombed_pieces()
			state = move
		elif current_booster_type == "Key Piece":
			var temp = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			if is_in_grid(temp.x, temp.y):
				if all_pieces[temp.x][temp.y] !=null:
					all_pieces[temp.x][temp.y].is_row_bomb = true
					all_pieces[temp.x][temp.y].matched = true
					get_bombed_pieces()
			state = move
	
func _on_buttom_ui_booster_pressed(boosterType):
		make_booster_active(boosterType)

func make_booster_active(boosterYype):
	if state == move:
		state = booster
		current_booster_type = boosterYype
	elif state == booster:
		state = move
		current_booster_type = ''

'''
	Removes lock piece on given space
'''
func _on_lock_holder_remove_lock(place):
	#Iterate through lock_spaces array from the size-1, going back one each time, at intervals of -1
	for i in range(lock_spaces.size()-1, -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove_at(i)
	remove_from_array(lock_spaces, place)

func _on_hint_timer_timeout():
	generate_hint()
	
'''
	Removes safe piece on given space
'''
func _on_safe_holder_remove_safe(place):
	remove_from_array(safe_spaces, place)


func _on_goal_holder_game_won():
	state = wait

