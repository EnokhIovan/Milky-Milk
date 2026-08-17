extends Area2D

@export var id: String = ""

var player_inside: Node = null

func check_shard_color():
	$AnimatedSprite2D.play(id)

func _physics_process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()
	
	check_shard_color()
	
	if SaveManager.is_shard_picked(id):
		queue_free()

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
			SaveManager.pick_shard(id)
			queue_free()
	else:
		for body in get_tree().get_nodes_in_group("player"):
			body.interaction_prompt.visible = false
