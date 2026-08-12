extends Area2D

@export var portal_id: String
@export_file("*.tscn") var target_scene: String
@export var target_portal_id: String

var player_inside := false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false


func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		print("Pressed")
		SceneTransition.change_scene(target_scene, target_portal_id)
