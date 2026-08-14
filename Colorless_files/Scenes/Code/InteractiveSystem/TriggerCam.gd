extends Area2D
@export var target_zoom: float = 4.0
@export var zoom_duration: float = 0.5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var camera = body.get_node("Camera2D")
		var tween := get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), zoom_duration)
