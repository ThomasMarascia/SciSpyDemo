extends Node2D

@export var health: int
@export var color: String

signal visible_damage

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(damage):
	health -= damage
	emit_signal("visible_damage", health)
	# Damage effects can be added here
	
