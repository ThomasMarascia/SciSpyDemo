extends Node2D

# level stuff
@export var level: int
@export var level_to_load: String
@export var enabled: bool
@export var score_goal_met: bool

# texture stuff
@export var blocked_texture: Texture
@export var open_texture: Texture
@export var goal_met: Texture
@export var goal_not_met: Texture

# update textures
@onready var level_label = $TextureButton/Level
@onready var button = $TextureButton
@onready var star = $Star
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDataManager.level_info.has(level):
		enabled = GameDataManager.level_info[level]["unlocked"]
	else:
		enabled = false
	setup()


func setup():
	level_label.text = str(level)
	if enabled:
		button.texture_normal = open_texture
	else:
		button.texture_normal = blocked_texture
	if score_goal_met:
		star.texture = goal_met
	else:
		star.texture = goal_not_met


func _on_texture_button_pressed():
	if enabled:
		print("loading level: ", level_to_load)
		get_tree().change_scene_to_file(level_to_load)
		SaveandLoad.lives = SaveandLoad.lives - 1
	print("Lives: ", SaveandLoad.lives)
