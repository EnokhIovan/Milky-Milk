class_name PaintSystem


static func calculate_grid_size(tilemap: TileMapLayer) -> Vector2i:
	var atlas_source := tilemap.tile_set.get_source(0) as TileSetAtlasSource

	if atlas_source == null:
		push_error("Source 0 bukan TileSetAtlasSource, cek tileset kamu")
		return Vector2i(6, 4)

	var texture_size: Vector2 = atlas_source.texture.get_size()
	var tile_size: Vector2i = tilemap.tile_set.tile_size

	var total_cols: int = int(texture_size.x / tile_size.x)
	var total_rows: int = int(texture_size.y / tile_size.y)

	var grid_cols = total_cols / 2
	var grid_rows = total_rows / 2

	return Vector2i(grid_cols, grid_rows)


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
