extends Node
'''
	THIS IS AN AUTOLOADED (GLOBAL) SCRIPT. ALL VARIABLES AND
	METHODS (CALLABLES) CAN BE CALLEDANYWHERE IN THE PROGRAM 
	WITH SaveandLoad.<variable> or SaveandLoad.<callable>
'''


''' GLOBAL VARIABLES '''
@export var email: String
@export var coins: int
@export var levelsComplete: Array 
@export var lives: int
@export var characters: Array
@export var activeCharacter: String
@export var timeLastSaved: Dictionary
@export var timeTillLife: int
#@export var exampleGlobalVariableToSave: type

var databaseCollection
var databaseUserDocument = null
var timeSince = 0

# Load all data from database document to global variables
func load_game(doc, col):
	databaseUserDocument = doc
	databaseCollection = col
	var userData = databaseUserDocument["doc_fields"]
	
	'''VARIABLES TO LOAD'''
	email = userData["email"]
	coins = userData["coins"]
	levelsComplete = userData["levelsComplete"]
	lives = userData["Lives"]
	characters = userData["charactersOwned"]
	activeCharacter = userData["characterActive"]
	timeLastSaved = userData["timeLastSaved"]
	timeTillLife = userData["timeTillLife"]
#	exampleGlobalVariableToSave = userData["exampleGlobalVariableToSave"]
	
	# time since the game saved last
	timeSince = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system(true)) - Time.get_unix_time_from_datetime_dict(timeLastSaved)

# Save the game to the online database. Call this with Saveload.save_game() 
# anywhere to save current game according to SaveandLoad global variables.
# run this after checkpoints (ex: levels complete) or store purchases
func save_game():
	timeLastSaved = Time.get_datetime_dict_from_system(true)
	
	'''VARIABLES TO SAVE'''
	var savedData = {
		"email": email,
		"coins": coins,
		"levelsComplete": levelsComplete,
		"Lives": lives,
		"charactersOwned": characters,
		"characterActive": activeCharacter,
		"timeLastSaved": timeLastSaved,
		"timeTillLife": timeTillLife
#		"exampleGlobalVariableToSave": exampleGlobalVariableToSave
	}
	var up_task: FirestoreTask = databaseCollection.update(databaseUserDocument["doc_name"], savedData)
	databaseUserDocument = await up_task.task_finished

# Save the game. Call this with Saveload.save_game() anywhere with all the CORRECT info
# Do not call this unless you are Tommy or you are sure of what you're doing
func save_game_WITH_DICTIONARY(doc, collection):
	timeLastSaved = Time.get_datetime_dict_from_system(true)
	var userData = doc["doc_fields"]

	'''VARIABLES TO SAVE'''
	var savedData = {
		"email": userData["email"],
		"coins": userData["coins"],
		"levelsComplete": userData["levelsComplete"],
		"Lives": userData["Lives"],
		"charactersOwned": userData["charactersOwned"],
		"characterActive": userData["characterActive"],
		"timeLastSaved": timeLastSaved,
		"timeTillLife": userData["timeTillLife"]
#		"exampleGlobalVariableToSave": userData["exampleGlobalVariableToSave"]
	}
	var up_task: FirestoreTask = collection.update(doc["doc_name"], savedData)
	databaseUserDocument = await up_task.task_finished
	
	
