extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	BoosterInfo.booster_info[1] = "Flask Bomb"
	BoosterInfo.booster_info[2] = "Sniper Piece"
	BoosterInfo.booster_info[3] = "Key Piece"
	activate_booster_buttons()


# This function just tells which of the buyable boosters to turn on

func activate_booster_buttons():
	for i in range (1, get_child_count()):
		if get_child(i).is_in_group("Boosters"):
			if BoosterInfo.booster_info[i] == "":
				get_child(i).check_active(false, null)
			else:
				get_child(i).check_active(true, BoosterInfo.booster_info[i])
