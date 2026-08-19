extends Area2D

@export var id: String = ""

var player_inside := false

func check_shard_color():
	$AnimatedSprite2D.play(id)

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("player"):
		body.interaction_prompt.visible = true
		player_inside = true

func _on_body_exited(body: CharacterBody2D):
	if body.is_in_group("player"):
		body.interaction_prompt.visible = false
		player_inside = false

func _physics_process(_delta: float) -> void:
	check_shard_color()
	
	if SaveManager.is_shard_picked(id):
		queue_free()
	
	if player_inside == true and Input.is_action_just_pressed("interact"):
			get_tree().current_scene.get_node("Player/InteractionPrompt").visible = false
			SaveManager.pick_shard(id)
			queue_free()
