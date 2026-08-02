class_name PaintSystem


static func calculate_grid_size(tilemap: TileMapLayer) -> Vector2i:
	return Vector2i(6, 4)


static func paint_one(
	tilemap: TileMapLayer,
	cell: Vector2i,
	current_color: int,
	grid_cols: int,
	grid_rows: int
) -> void:
	var source_id = tilemap.get_cell_source_id(cell)

	if source_id == -1:
		return

	if grid_cols == 0 or grid_rows == 0:
		return

	var atlas_source := tilemap.tile_set.get_source(source_id) as TileSetAtlasSource

	if atlas_source == null:
		return

	var atlas = tilemap.get_cell_atlas_coords(cell)

	var shape_x = atlas.x % grid_cols
	var shape_y = atlas.y % grid_rows

	var new_atlas: Vector2i

	match current_color:
		0:
			new_atlas = Vector2i(shape_x, shape_y)
		1:
			new_atlas = Vector2i(
				shape_x + grid_cols,
				shape_y
			)
		2:
			new_atlas = Vector2i(
				shape_x + grid_cols,
				shape_y + grid_rows
			)
		_:
			new_atlas = atlas

	if not atlas_source.has_tile(new_atlas):
		push_warning(
			"Tile atlas %s belum dibuat di TileSet editor!"
			% str(new_atlas)
		)
		return

	tilemap.set_cell(
		cell,
		source_id,
		new_atlas
	)


static func get_tile_color(
	tilemap: TileMapLayer,
	cell: Vector2i,
	grid_cols: int,
	grid_rows: int
) -> int:
	var source = tilemap.get_cell_source_id(cell)

	if source == -1:
		return -1

	var atlas = tilemap.get_cell_atlas_coords(cell)

	if atlas.y < grid_rows and atlas.x < grid_cols:
		return 0

	if atlas.y < grid_rows and atlas.x >= grid_cols:
		return 1

	if atlas.y >= grid_rows and atlas.x >= grid_cols:
		return 2

	return 3
