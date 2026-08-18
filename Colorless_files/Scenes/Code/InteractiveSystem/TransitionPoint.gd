extends Area2D

@export var id: String = ""

@export_category("Destination")
@export_file("*.tscn") var destination_scene: String = ""
@export var destination_id: String = ""

var player_inside := false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		if destination_scene != "" and destination_id != "":
			body.interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		body.interaction_prompt.visible = false

func complete_level_if_exit():
	if id.ends_with("Gex"):
		var level_id := id.trim_prefix("L").trim_suffix("Gex")
		SaveManager.complete_level("Level" + level_id)

func _process(_delta: float) -> void:
	if player_inside and destination_scene != "" and destination_id != "":
		if player_inside and Input.is_action_just_pressed("interact"):
			if destination_scene == "" or destination_id == "":
				return
			
			complete_level_if_exit()
			
			SceneTransition.change_scene(
				destination_scene,
				destination_id
			)
