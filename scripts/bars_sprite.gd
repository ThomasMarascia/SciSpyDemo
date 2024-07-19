extends Sprite2D

#Different bars textures
@export var damageStage2 = preload("res://art/bars_piece_stage2.png")
@export var damageStage3 = preload("res://art/bars_piece_stage3.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Changes the bars to look more "broken" each time they are damaged
func _on_bars_piece_visible_damage(health):
	if health == 2:
		set_texture(damageStage2)
	if health == 1:
		set_texture(damageStage3)
