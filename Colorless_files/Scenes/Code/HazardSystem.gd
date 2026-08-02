class_name HazardSystem

static func check_trampoline(
	tilemap: TileMapLayer,
	rect: Rect2,
	gravity: float,
	bounce_height: float,
	current_velocity_y: float,
	grid_cols: int,
	grid_rows: int
) -> float:
	var bottom_y = rect.position.y + rect.size.y
	var center_x = rect.position.x + rect.size.x / 2.0
	var cell = tilemap.local_to_map(tilemap.to_local(Vector2(center_x, bottom_y + 2)))
	var atlas = tilemap.get_cell_atlas_coords(cell)
	var color = PaintSystem.get_tile_color(tilemap, cell, grid_cols, grid_rows)
	print("cell=", cell, " atlas=", atlas, " color=", color, " grid=", grid_cols, "x", grid_rows)
	if color == 2:
		return -sqrt(2 * gravity * bounce_height)
	return current_velocity_y

static func check_spike(
	spike_tilemap: TileMapLayer,
	rect: Rect2
) -> bool:
	if spike_tilemap == null:
		return false
	var points = [
		rect.position,
		Vector2(rect.position.x + rect.size.x, rect.position.y),
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		rect.position + rect.size,
		rect.position + rect.size / 2.0
	]
	for p in points:
		var cell = spike_tilemap.local_to_map(spike_tilemap.to_local(p))
		var source = spike_tilemap.get_cell_source_id(cell)
		if source != -1:
			return true
	return false
