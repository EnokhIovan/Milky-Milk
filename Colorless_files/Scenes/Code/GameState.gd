extends Node

var current_level_id: String = ""
var current_color: int = 0
var levels: Dictionary = {}

func change_level_state(new_level_id: String) -> void:
	var new_main_level := get_main_level_id(new_level_id)
	var current_main_level := get_main_level_id(current_level_id)

	# Kalau pindah dari L14 ke L15, hapus semua state L14.
	if current_main_level != "" and new_main_level != current_main_level:
		clear_level()

	current_level_id = new_level_id

func get_main_level_id(level_id: String) -> String:
	if level_id == "":
		return ""

	var s_index := level_id.find("S")

	if s_index == -1:
		return level_id

	return level_id.substr(0, s_index)


func get_level_state(level_id: String) -> Dictionary:
	if not levels.has(level_id):
		levels[level_id] = {
			"tiles": {},
			"items": {}
		}

	return levels[level_id]


func clear_level() -> void:
	levels.clear()
	current_level_id = ""
	current_color = 0
