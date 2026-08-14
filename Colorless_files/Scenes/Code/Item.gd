extends Area2D

@export var item_id: String


func _ready():
	var map = get_tree().current_scene
	var level_id: String = map.level_id

	var state = GameState.get_level_state(level_id)

	if state["items"].get(item_id, false):
		queue_free()

func collect():
	var map = get_tree().current_scene
	var level_id: String = map.level_id

	var state = GameState.get_level_state(level_id)

	state["items"][item_id] = true

	queue_free()
