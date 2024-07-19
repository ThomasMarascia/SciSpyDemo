extends "res://scripts/BaseMenuPanel.gd"

signal start_pressed

# textures
@export var avatar0: Texture
@export var avatar1: Texture
@export var avatar2: Texture

# game start button pressed
func _on_button_2_pressed():
	emit_signal("start_pressed")

# vars
var numCoins: int = 0
var numLives: int = 0
var timeLives: int = 1800
var timeInMins: int = 30
var timeInSec: int = 0

# update the home screen when given database doc, called from Game Menu
func _on_game_menu_update_home(doc):
	var userData = doc["doc_fields"]
	numLives = userData["Lives"]
	numCoins = userData["coins"]
	print("updating home screen with values: \n, \tcoins: $", numCoins, " \n\tlives: ", numLives)
	
	# change the actual text of the moneyNum node
	var strCenter = "[center] $"+str(numCoins)+"[/center]"
	$money/moneyNum.text = strCenter
	
	# use the time since from SaveandLoad to find out how many lives the player
	# should have now
	SaveandLoad.timeSince = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system(true)) - Time.get_unix_time_from_datetime_dict(userData["timeLastSaved"])
	var timeAdd = SaveandLoad.timeSince
	timeAdd = SaveandLoad.timeSince+(timeLives-SaveandLoad.timeTillLife)
	while timeAdd >= timeLives:
		timeAdd -= timeLives
		numLives += 1
	
	# set timeLives to how many seconds was left when subtracting remaining timeAdd
	timeLives = timeLives - abs(timeAdd)
	
	# if they have less than 5 lives, start the timer to get more
	if(numLives < 5):
		$lives/Timer.start()
	else:
		numLives = 5
	
	# set the livesNum node's text
	strCenter = "[center]"+str(numLives)+"[/center]"
	$lives/LivesNum.text = strCenter
	
	# update the database with the new lives
	SaveandLoad.lives = numLives
	
	SaveandLoad.save_game()
	
	
	
# every second when timer is on
func _on_timer_timeout():
	numLives = int($lives/LivesNum.text[8])
	timeLives -= 1
	SaveandLoad.timeTillLife -= 1
	timeInMins = int(floor(float(timeLives)/60))
	timeInSec = timeLives%60
	if(timeInSec > 9):
		$lives/LivesTime.text = "[center]"+str(timeInMins)+" : "+str(timeInSec)+"[/center]"
	else:
		$lives/LivesTime.text = "[center]"+str(timeInMins)+" : 0"+str(timeInSec)+"[/center]"
	
	# When timeLives hits 0, increment how many lives the player has and start the timer 
	# over if the player has less than 5 lives still
	if(timeLives < 0):
		print("+1 life numlives: ", numLives)
		timeLives = 1800
		SaveandLoad.timeTillLife = 1800
		numLives += 1
		$lives/LivesNum.text = "[center]"+str(numLives)+"[/center]"
		if(numLives >= 5):
			$lives/LivesTime.text = "[center]Full[/center]"
			$lives/Timer.stop()

func change_avatar():
	# updates the avatar texture based on the number
	# can add more elifs upon more avatars
	if ConfigManager.avatar == 0:
		$"MarginContainer/Buttons and Graphics/Buttons/Button1".texture_normal = avatar0
	elif ConfigManager.avatar == 1:
		$"MarginContainer/Buttons and Graphics/Buttons/Button1".texture_normal = avatar1
	else:
		$"MarginContainer/Buttons and Graphics/Buttons/Button1".texture_normal = avatar2

func _on_game_menu_read_avatar():
	change_avatar()

func _on_button_1_pressed():
	# changes avatar when button is pressed
	# IF ADDED MORE AVATARS, update the mod
	ConfigManager.avatar = (ConfigManager.avatar + 1) % 3
	print(ConfigManager.avatar)
	change_avatar() 
	ConfigManager.save_config() # make sure to save preference back to config
