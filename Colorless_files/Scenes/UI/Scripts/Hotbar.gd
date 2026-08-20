extends CanvasLayer

@onready var color_rect = $ColorRect

var colors: Array[Color] = [
	Color.WHITE,
	Color("#569FE8"),
	Color("#66E133"),
	Color("#8700E8")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	color_rect.color = colors[GameState.current_color]
