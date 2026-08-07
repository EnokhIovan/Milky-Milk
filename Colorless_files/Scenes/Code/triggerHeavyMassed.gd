extends Area2D

@export var blackhole: Node2D
@export var ground_layers: Array[TileMapLayer] = []   # drag Ground & Decor ke sini
@export var gravitation_particles: GPUParticles2D
@export var dust_particles_scene: PackedScene
@export var gravity_field: Area2D
@export var sky_height: float = 200.0
@export var rise_duration: float = 5.8

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true

	if gravitation_particles:
		gravitation_particles.emitting = true
	if gravity_field:
		gravity_field.active = true

	var target_y = blackhole.global_position.y - sky_height
	var tween = create_tween()
	tween.tween_property(blackhole, "global_position:y", target_y, rise_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	suck_ground()

func suck_ground() -> void:
	# --- kumpulin semua cell dari semua layer jadi 1 list ---
	var all_pieces: Array = []  # tiap item: {layer, cell, world_pos}

	for layer in ground_layers:
		var cells = layer.get_used_cells()
		for cell in cells:
			var source_id = layer.get_cell_source_id(cell)
			if source_id == -1:
				continue
			var world_pos = layer.to_global(layer.map_to_local(cell))
			all_pieces.append({
				"layer": layer,
				"cell": cell,
				"world_pos": world_pos
			})

	# --- sort gabungan berdasarkan posisi X di world, kiri ke kanan ---
	all_pieces.sort_custom(func(a, b): return a.world_pos.x < b.world_pos.x)

	var delay := 0.0
	var step := 0.08

	for piece_data in all_pieces:
		var layer: TileMapLayer = piece_data.layer
		var cell: Vector2i = piece_data.cell
		var world_pos: Vector2 = piece_data.world_pos

		var source_id = layer.get_cell_source_id(cell)
		var atlas_coords = layer.get_cell_atlas_coords(cell)
		var source = layer.tile_set.get_source(source_id)
		var texture = source.texture
		var tile_size = layer.tile_set.tile_size

		process_single_piece(layer, cell, texture, atlas_coords, tile_size, world_pos, delay)
		delay += step

func process_single_piece(layer: TileMapLayer, cell: Vector2i, texture: Texture2D, atlas_coords: Vector2i, tile_size: Vector2i, world_pos: Vector2, delay: float) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	layer.erase_cell(cell)

	if dust_particles_scene:
		var dust = dust_particles_scene.instantiate()
		get_tree().current_scene.add_child(dust)
		dust.global_position = world_pos
		dust.burst()

	var sprite = Sprite2D.new()
	sprite.set_script(preload("res://Colorless_files/Scenes/Code/groundPiece.gd"))
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(atlas_coords * tile_size, tile_size)
	sprite.global_position = world_pos
	get_tree().current_scene.add_child(sprite)

	sprite.start_suck(blackhole, 0.0)
