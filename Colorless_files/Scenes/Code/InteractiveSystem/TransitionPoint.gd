extends Area2D

@export var id: String = ""

@export_category("Destination")
@export_file("*.tscn") var destination_scene: String = ""
@export var destination_id: String = ""

var player_inside := false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		if destination_scene == "" or destination_id == "":
			return

		SceneTransition.change_scene(
			destination_scene,
			destination_id
		)
