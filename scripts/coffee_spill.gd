extends Node2D

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("coffee_spill") 


func _on_animated_sprite_2d_animation_finished():
	queue_free() # Replace with function body.
