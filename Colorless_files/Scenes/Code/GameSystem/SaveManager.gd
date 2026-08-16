extends Node

const SAVE_PATH := "user://savegame.json"

var data := {
	"completed_levels": []
}

func _ready() -> void:
	load_game()

func complete_level(level_id: String) -> void:
	if not is_level_completed(level_id):
		data["completed_levels"].append(level_id)
		save_game()

		print("Level selesai: ", level_id)

func is_level_completed(level_id: String) -> bool:
	return level_id in data["completed_levels"]

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Gagal membuka save file")
		return

	file.store_string(JSON.stringify(data))
	file.close()

	print("Game saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Belum ada save file")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("Gagal membuka save file")
		return

	var json := JSON.new()
	var result := json.parse(file.get_as_text())

	file.close()

	if result != OK:
		print("Save file rusak")
		return

	if typeof(json.data) == TYPE_DICTIONARY:
		data = json.data
		print("SAVE DATA:")
		print(JSON.stringify(data, "\t"))

	print("Game loaded")
	print("Completed levels: ", data["completed_levels"])
