extends Node

var destination_id: String = ""


func change_scene(scene_path: String, id: String) -> void:
	destination_id = id

	var error := get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error("Gagal pindah scene: " + scene_path)
		return

	await get_tree().scene_changed

	move_player_to_destination()


func move_player_to_destination() -> void:
	if destination_id == "":
		return

	var destination := find_by_id(
		get_tree().current_scene,
		destination_id
	)

	if destination == null:
		push_warning("Objek dengan ID tidak ditemukan: " + destination_id)
		return

	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("Player tidak ditemukan.")
		return

	player.global_position = destination.global_position

	destination_id = ""


func find_by_id(node: Node, id: String) -> Node:
	for child in node.get_children():
		if child.get("id") == id:
			return child

		var result := find_by_id(child, id)

		if result != null:
			return result

	return null
