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

# Reset progress SATU level_id spesifik (dipanggil pas tombol Restart).
# Cuma hapus data level itu, gak nyentuh level lain / current_level_id.
func reset_current_level_progress(level_id: String) -> void:
	if levels.has(level_id):
		levels[level_id] = {
			"tiles": {},
			"items": {}
		}

# Reset SEMUA sub-level dalam satu main level (misal restart L14 harus
# nge-reset L14S1, L14S2, dst juga -- pakai ini kalau restart dimaksudkan
# ngulang dari sub-level pertama main level itu).
func reset_main_level_progress(level_id: String) -> void:
	var main_id := get_main_level_id(level_id)
	var keys_to_reset := []
	for key in levels.keys():
		if get_main_level_id(key) == main_id:
			keys_to_reset.append(key)
	for key in keys_to_reset:
		levels[key] = {"tiles": {}, "items": {}}
