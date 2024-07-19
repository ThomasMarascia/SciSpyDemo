extends Node2D

# pieces Variables
# Color variable: will probably use this later to check for matches
@export var color: String;

@export var row_texture: Texture
@export var column_texture: Texture
@export var adjacent_texture: Texture
@export var color_texture: Texture
@export var square_texture: Texture
@export var bree_special: Texture
@export var tugood_special: Texture
@export var james_special: Texture

var is_bomb = false
var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false
var is_color_bomb = false
var is_square_bomb = false
var is_row_col_combo = false
var is_x_combo = false
var is_adj_combo = false
var is_adj_color = false
var is_col_color = false
var is_row_color = false
var is_square_color = false
var path_of_bomb = false
var drop = false
var special_piece = false

#this variable holds the id of the avatar selected by the user (stored in the config file)
var avatar = ConfigManager.avatar

#Tween node in scene editor was phased out in version 4, so it has been places as a regular node
var move_tween;
var matched = false;

# Strengh variable: might use this to scale difficulty? (like a strength of 2 takes 2 matches to break maybe?)
@export var strength: int;

@export var weight: float;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

'''
	this function will move a piece from one location to another with transition animation
'''
func move(target):
	#move_tween makes itself a tween inside the script due to version 4 differences
	move_tween = self.create_tween();
	#the tween will move from current position to target position with transitions
	move_tween.tween_property(self, "position", target, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	move_tween.play();
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

#dims the color of piece
func dim():
	var sprite = get_node("Sprite2D");
	sprite.modulate = Color(1, 1, 1, .5);
	pass;

func swell():
	var sprite = get_node("Sprite2D")
	sprite.scale *= 1.10

func blink():
	var sprite = get_node("Sprite2D");
	sprite.modulate = Color(1, 1, 1, .25);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, 1);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, .25);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, 1);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, .25);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, 1);
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, .25);

''' 
	The following three functions will change a normal piece to a bomb piece	
'''	
func make_column_bomb():
	is_bomb = true
	is_column_bomb = true
	$Sprite2D.texture = column_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)
	
func make_row_bomb(a = 10):
	is_bomb = true
	is_row_bomb = true
	if a == 2:
		$Sprite2D.texture = james_special
		$Sprite2D.modulate = Color(1, 1, 1, 1)
		special_piece = true
	else:
		$Sprite2D.texture = row_texture
		$Sprite2D.modulate = Color(1, 1, 1, 1)
	
func make_adjacent_bomb(a = 10):
	is_bomb = true
	is_adjacent_bomb = true
	if a == 1:
		$Sprite2D.texture = tugood_special
		$Sprite2D.modulate = Color(1, 1, 1, 1)
		special_piece = true
	else:
		$Sprite2D.texture = adjacent_texture
		$Sprite2D.modulate = Color(1, 1, 1, 1)

func make_color_bomb(a = 10):
	is_bomb = true
	is_color_bomb = true
	if a == 0:
		$Sprite2D.texture = bree_special
		$Sprite2D.modulate = Color(1, 1, 1, 1)
		special_piece = true
	else:
		$Sprite2D.texture = color_texture
		$Sprite2D.modulate = Color(1, 1, 1, 1)

func make_square_bomb():
	is_bomb = true
	is_square_bomb = true
	$Sprite2D.texture = square_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)
