extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for Row in $LevelBoxNode.get_children():
		print(Row.name)
		for LevelBox in Row.get_children():
			var index: int = int((LevelBox.name).trim_prefix("LevelBox")) + (int((Row.name).trim_prefix("Row")) - 1)*5
			LevelBox.get_node("Label").text = str(index)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
