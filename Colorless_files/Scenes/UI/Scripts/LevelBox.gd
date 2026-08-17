extends TextureButton

@export_file("*.tscn") var target_scene: String

func _on_pressed() -> void:
	if target_scene.is_empty():
		push_warning("Target scene belum diisi!")
		return
	
	if $Lock.visible == false:
		get_tree().change_scene_to_file(target_scene)
