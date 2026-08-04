class_name HazardSystem

static func check_trampoline(
	tilemap: TileMapLayer,
	rect: Rect2,
	gravity: float,
	bounce_height: float,
	current_velocity_y: float
) -> float:
	var bottom_y = rect.position.y + rect.size.y + 2
	var left_x = rect.position.x + 1
	var right_x = rect.position.x + rect.size.x - 1

	var cell_left = tilemap.local_to_map(tilemap.to_local(Vector2(left_x, bottom_y)))
	var cell_right = tilemap.local_to_map(tilemap.to_local(Vector2(right_x, bottom_y)))

	for x in range(cell_left.x, cell_right.x + 1):
		var cell = Vector2i(x, cell_left.y)
		var color = PaintSystem.get_tile_color(tilemap, cell)
		if color == 2:  # hijau = trampoline
			return -sqrt(2 * gravity * bounce_height)

	return current_velocity_y


# Cek warna tile tepat di bawah kaki (dipakai buat speed tile, dsb)
static func check_ground_color(tilemap: TileMapLayer, rect: Rect2) -> int:
	var bottom_center = Vector2(
		rect.position.x + rect.size.x / 2.0,
		rect.position.y + rect.size.y + 2
	)
	var cell = tilemap.local_to_map(tilemap.to_local(bottom_center))
	return PaintSystem.get_tile_color(tilemap, cell)


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
