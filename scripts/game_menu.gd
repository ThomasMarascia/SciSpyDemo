extends Control
signal updateHome
signal docIsReady
signal read_sound
signal read_music
signal read_avatar
@onready var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('users')

# logging in this way for demo 
var email = "newUser2@gmail.com"
var pwd = "greatPassword123"

# variables
var customStats: bool = true
var path
var document: FirestoreDocument = null


# stats a new user starts with
var startingStats
var startingStatsNorm = {
	"email": email,
	"coins": 50,
	"levelsComplete": [],
	"Lives": 5,
	"charactersOwned": ["cat"],
	"characterActive": "cat",
	"timeLastSaved": Time.get_datetime_dict_from_system(true),
	"timeTillLife": 1800#,
#	"examplekey": default value
}
var startingStatsTest = {
	"email": email,
	"coins": 5000,
	"levelsComplete": [0, 1, 2, 3, 4],
	"Lives": 2,
	"charactersOwned": ["cat"],
	"characterActive": "cat",
	"timeLastSaved": Time.get_datetime_dict_from_system(true),
	"timeTillLife": 800#,
#	"examplekey": default value
}

# Once the data is loaded add anything game start related here:
func _on_doc_is_ready():
	$MainMenu.slide_in()
	
	
	# deletes the profile current logged in and the corresponding doc (danger)
#	delProfile()
	
	

# Called when the node enters the scene tree for the first time.
# connect all signals needed and sign in. set custom sets if needed
func _ready():
	if customStats:
		startingStats = startingStatsTest
	else:
		startingStats = startingStatsNorm
	Firebase.Auth.connect("signup_succeeded", _on_signup_succeeded)
	Firebase.Auth.connect("signup_failed", _on_signup_failed)
	Firebase.Auth.connect("login_failed", _on_login_failed)
	Firebase.Auth.connect("login_succeeded", _on_login_succeeded)
	
	Firebase.Auth.signup_with_email_and_password(email, pwd)

# set the stats of the world to the stats pulled
func setStats(doc):
	SaveandLoad.load_game(doc, firestore_collection)
	emit_signal("updateHome", doc)

# delete the user and his document
func delProfile():
	print("deleting user with localid = ", document["doc_name"])
	await get_tree().create_timer(2).timeout
	# just in case it's called instantly after the game starts, we have to wait
	# for the document to be created before we delete it or else it will try
	# to delete nothing and then create a document for a user that will be deleted
	while SaveandLoad.databaseUserDocument == null:
		print("waiting for document build")
		await get_tree().create_timer(1).timeout
	var del_task: FirestoreTask = firestore_collection.delete(document["doc_name"])
	if await del_task.delete_document:
		Firebase.Auth.delete_user_account()
		print(await Firebase.Auth.auth_request)
		get_tree().quit()
	else:
		print("Failed to delete account")

# if the sign up was successful, create new database entry
func _on_signup_succeeded(auth_info):
	print("Signup successful\n \tuser localid: ", auth_info["localid"])
	path = auth_info["localid"]
	var add_task: FirestoreTask = firestore_collection.add(path, startingStats)
	document = await add_task.add_document
	checkDataDocument(document)
	setStats(document)

# if sign up was failed, try to login if that email existed
func _on_signup_failed(code, msg):
	if msg == "EMAIL_EXISTS":
		print("user exists: logging in")
		Firebase.Auth.login_with_email_and_password(email, pwd)
	else:
		print("signup failed: ", code, ": ", msg)

# If login worked, get document 
func _on_login_succeeded(auth_info):
	path = auth_info["localid"]
	var document_task: FirestoreTask = firestore_collection.get_doc(path)
	document = await document_task.get_document
	print("Login successful, \n \tuser localid: ", auth_info["localid"])
	checkDataDocument(document)
	setStats(document)
	
# Checks if the document has the most updated data types. Very useful for when
# you add something to the databases
func checkDataDocument(doc):
	if doc["doc_fields"].keys().size() == startingStats.keys().size():
		print("Document is up to date")
	else:
		var missingData: int = 0
		for key in startingStats:
			if not doc["doc_fields"].has(key):
				missingData += 1
				document["doc_fields"][key] = startingStats[key]
		print("doc was missing ", missingData, " fields")
		doc = document
		SaveandLoad.save_game_WITH_DICTIONARY(doc, firestore_collection)
	emit_signal("docIsReady")
	
# if login failed
func _on_login_failed(code, msg):
	print("LOGIN_ERROR: ", code, ": ", msg)
	

func _on_home_screen_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_backdrop.tscn")

func _on_settings_back_button():
	$Settings.slide_out()
	$MainMenu.slide_in()

func _on_main_menu_play_pressed():
	emit_signal("read_avatar") # update the avatar upon home screen
	$MainMenu.slide_out()
	$home_screen.slide_in()

func _on_main_menu_settings_pressed():
	# update sound/music upon opening settings
	emit_signal("read_sound")
	emit_signal("read_music")
	$MainMenu.slide_out()
	$Settings.slide_in()

# change the sound to be the opposite when the button is pressed
func _on_settings_sound_change():
	ConfigManager.sound_on = !ConfigManager.sound_on
