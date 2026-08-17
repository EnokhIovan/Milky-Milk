extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for Row in $LevelBoxNode.get_children():
		print(Row.name)
		for LevelBox in Row.get_children():
			var index: int = int((LevelBox.name).trim_prefix("LevelBox")) + (int((Row.name).trim_prefix("Row")) - 1)*5
			LevelBox.target_scene = "res://Colorless_files/Scenes/Levels/level_" + str(index) + ".tscn"
			
			if SaveManager.is_level_completed("Level" + str(index)):
				var texture_rect: TextureRect = LevelBox.get_node("TextureRect")
				var atlas: AtlasTexture = texture_rect.texture.duplicate()

				texture_rect.texture = atlas
				atlas.region.position.x += 64
				LevelBox.get_node("Label").add_theme_color_override("font_color", Color.WHITE)
			LevelBox.get_node("Label").text = str(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
