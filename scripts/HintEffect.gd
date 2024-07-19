extends Node2D

@onready var this_sprite = $Sprite2D
@onready var size_tween = create_tween()
@onready var color_tween = create_tween()


func _ready():
	Setup(this_sprite.texture)

func Setup(new_sprite):
	this_sprite.texture = new_sprite
	slowly_larger()
	slowly_dimmer()
	
func slowly_larger():
#	size_tween.tween_property(this_sprite, "scale", Vector2(1,1), 1.5)
	size_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	size_tween.tween_property(this_sprite, "scale", Vector2(1.25,1.25), 1.5)
	size_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	color_tween.finished.emit(slowly_larger)

func slowly_dimmer():
#	color_tween.tween_property(this_sprite, "modulate", Color(1,1,1,1), 1.5)
	color_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
#	color_tween.tween_property(this_sprite, "modulate", Color (1,1,1,.5), 1.5)
	color_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	color_tween.finished.emit(slowly_dimmer)
