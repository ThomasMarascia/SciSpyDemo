extends Node2D

@export var health: int
@export var color: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(damage):
	health -= damage
	# Damage effects can be added here
