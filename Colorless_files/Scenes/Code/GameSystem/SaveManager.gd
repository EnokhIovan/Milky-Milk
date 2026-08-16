extends Node

const SAVE_PATH := "user://savegame.json"


var data := {
	"items": [],
	"completed_maps": [],
	"current_map": "",
	"player_position": {
		"x": 0.0,
		"y": 0.0
	}
}


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Gagal membuka save file")
		return

	file.store_string(JSON.stringify(data))
	file.close()

	print("Game berhasil disimpan")


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Belum ada save")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(json_text)

	if result != OK:
		print("Save file rusak")
		return

	data = json.data

	print("Game berhasil diload")


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	print("Save dihapus")
