extends TextureButton

enum {add_to_counter, make_color_bomb, destroy_piece}
var state

var active = false
var active_texture

@export var flask_piece_texture : Texture
@export var sniper_piece_texture : Texture
@export var key_piece_texture : Texture
var type = ""

func check_active(is_active, etype):
	if is_active:
		if etype == "Flask Piece":
			texture_normal = flask_piece_texture
			type = "Flask Piece"
		elif etype == "Sniper Piece":
			texture_normal = sniper_piece_texture
			type = "Sniper Piece"
		elif etype == "Key Piece":
			texture_normal = key_piece_texture
			type = "Key Piece"
	else:
		texture_normal = null
		type = ""
