extends Node

var target_portal_id: String = ""


func change_scene(scene_path: String, portal_id: String):
	target_portal_id = portal_id
	
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().scene_changed
	
	spawn_player_at_target()


func spawn_player_at_target():
	if target_portal_id == "":
		return

	var current_scene = get_tree().current_scene
	var target_portal = find_portal(current_scene, target_portal_id)

	if target_portal == null:
		push_warning("Portal tujuan tidak ditemukan: " + target_portal_id)
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("Player tidak ditemukan")
		return

	player.global_position = target_portal.global_position


func find_portal(node: Node, portal_id: String) -> Node:
	for child in node.get_children():

		if child.get("portal_id") == portal_id:
			return child

		var result = find_portal(child, portal_id)

		if result != null:
			return result

	return null
