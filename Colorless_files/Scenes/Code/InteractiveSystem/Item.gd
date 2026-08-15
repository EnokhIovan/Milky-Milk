extends Area2D

var player_inside: Node = null


func _physics_process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()

	player_inside = null

	for body in bodies:
		if body.is_in_group("player"):
			player_inside = body
			break

	# Update prompt
	if player_inside:
		player_inside.interaction_prompt.visible = true

		if Input.is_action_just_pressed("interact"):
			player_inside.interaction_prompt.visible = false
			queue_free()
	else:
		for body in get_tree().get_nodes_in_group("player"):
			body.interaction_prompt.visible = false
