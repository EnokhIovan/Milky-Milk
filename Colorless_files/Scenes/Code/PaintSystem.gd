class_name PaintSystem

# Bangun lookup table: [shape_id, color] -> atlas_coords
# Panggil sekali aja waktu _ready, simpan hasilnya, terus lempar ke paint_one().
static func build_color_lookup(tilemap: TileMapLayer) -> Dictionary:
	var lookup := {}
	var source := tilemap.tile_set.get_source(0) as TileSetAtlasSource
	
	if source == null:
		push_error("Source 0 bukan TileSetAtlasSource, cek tileset kamu")
		return lookup
	
	for i in source.get_tiles_count():
		var atlas_coords: Vector2i = source.get_tile_id(i)
		var tile_data := source.get_tile_data(atlas_coords, 0)
		
		if tile_data == null:
			continue
		
		var shape_id: int = tile_data.get_custom_data("shape_id")
		var color: int = tile_data.get_custom_data("color")
		var key = [shape_id, color]
		
		if lookup.has(key):
			push_warning(
				"Duplikat shape_id %s + color %s di tileset: atlas %s ketiban sama atlas %s"
				% [shape_id, color, lookup[key], atlas_coords]
			)
		
		lookup[key] = atlas_coords
	
	return lookup


# Balikin true kalau beneran berhasil ngecat
static func paint_one(
	tilemap: TileMapLayer,
	cell: Vector2i,
	current_color: int,
	color_lookup: Dictionary
) -> bool:
	var source_id = tilemap.get_cell_source_id(cell)
	
	if source_id == -1:
		return false
	
	var tile_data := tilemap.get_cell_tile_data(cell)
	
	if tile_data == null:
		return false
	
	var shape_id: int = tile_data.get_custom_data("shape_id")
	var key = [shape_id, current_color]
	
	if not color_lookup.has(key):
		push_warning(
			"Kombinasi shape_id %s + color %s belum ada di tileset!"
			% [shape_id, current_color]
		)
		return false
	
	var new_atlas: Vector2i = color_lookup[key]
	tilemap.set_cell(cell, source_id, new_atlas)
	
	return true


static func get_tile_color(tilemap: TileMapLayer, cell: Vector2i) -> int:
	var source = tilemap.get_cell_source_id(cell)
	
	if source == -1:
		return -1
	
	var tile_data := tilemap.get_cell_tile_data(cell)
	
	if tile_data == null:
		return -1
	
	return tile_data.get_custom_data("color")


static func reset_progress(level_id: String) -> void:
	GameState.reset_current_level_progress(level_id)
