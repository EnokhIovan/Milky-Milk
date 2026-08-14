extends Node2D

@export var level_id: String = ""
@onready var tilemap: TileMapLayer = $Ground
var color_lookup: Dictionary

func _ready():
	# Beritahu GameState kita sedang berada di level ini
	GameState.change_level_state(level_id)

	# Buat lookup warna dari TileSet Ground
	color_lookup = PaintSystem.build_color_lookup(tilemap)

	# Kembalikan perubahan tile yang sebelumnya sudah dilakukan
	restore_paint()

func restore_paint():
	var state = GameState.get_level_state(level_id)
	for cell in state["tiles"]:
		var color: int = state["tiles"][cell]

		PaintSystem.paint_one(
			tilemap,
			cell,
			color,
			color_lookup
		)
