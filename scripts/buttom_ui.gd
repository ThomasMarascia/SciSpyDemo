extends TextureRect

signal pause_game
signal booster_pressed

func _on_pause_pressed():
	pause_game.emit()
# 	emit_signal("pause_game") 
	get_tree().paused = true


func _on_booster_1_pressed():
	emit_signal("booster_pressed", BoosterInfo.booster_info[1])
#	emit_signal("booster_pressed", $MarginContainer/HBoxContainer/Booster1.type)


func _on_booster_2_pressed():
	emit_signal("booster_pressed", BoosterInfo.booster_info[2])


func _on_booster_3_pressed():
	emit_signal("booster_pressed", BoosterInfo.booster_info[3])
