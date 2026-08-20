extends CharacterBody2D

@export var speed := 150.0
@export var shoot_range := 150.0
@export var gravity := 800.0
@export var jump_height := 32.0
@export var can_jump := true
@export var bounce_height := 64.0
@export var fall_limit_y := 672.0
@export var allowed_colors: Array[int] = [0, 1, 2, 3]
@export var teleport_pre_delay := 0.2
@export var teleport_post_delay := 0.2
@export var tilemap_path: NodePath
@export var spike_tilemap_path: NodePath
@export var decor_tilemap_path: NodePath

var is_painting := false
var is_dead := false
var current_color := 0
var spawn_position: Vector2
var color_lookup: Dictionary = {}
var _was_on_floor := true
var is_teleporting := false
var _on_teleport_tile := false
var _current_teleport_cell: Vector2i = Vector2i(-999999, -999999)

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var interaction_prompt: Sprite2D = $InteractionPrompt
@onready var tilemap: TileMapLayer = get_node_or_null(tilemap_path)
@onready var spike_tilemap: TileMapLayer = get_node_or_null(spike_tilemap_path)
@onready var decor_tilemap: TileMapLayer = get_node_or_null(decor_tilemap_path)

func _ready():
	MusicPlayer.play("raining")
	sprite.animation_finished.connect(_on_animation_finished)
	color_lookup = PaintSystem.build_color_lookup(tilemap)
	sprite.play("Idle")
	spawn_position = global_position
	_was_on_floor = is_on_floor()
	_validate_allowed_colors()
	current_color = GameState.current_color

func _validate_allowed_colors() -> void:
	if allowed_colors.size() > 4:
		push_warning("allowed_colors punya lebih dari 4 elemen, cek lagi isinya!")
	for c in allowed_colors:
		if c < 0 or c > 3:
			push_warning("allowed_colors berisi nilai gak valid: %s (harus 0-3)" % c)

# --- Helper state ---
func _get_level_state() -> Dictionary:
	var level_id: String = get_tree().current_scene.name
	return GameState.get_level_state(level_id)

func _purple_paint_count() -> int:
	var tiles: Dictionary = _get_level_state().get("tiles", {})
	var count := 0
	for c in tiles.values():
		if c == 3:
			count += 1
	return count

# --- INPUT (mouse/keyboard event-based, otomatis di-skip kalau event ---
# --- udah "dimakan" duluan sama UI/Button, misal tombol Pause Menu)   ---
func _unhandled_input(event: InputEvent) -> void:
	if is_dead or is_teleporting or get_tree().paused:
		return

	if event.is_action_pressed("paint"):
		shoot_paint(get_global_mouse_position())
		Audio.play("paint")
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()

func _physics_process(delta):
	if is_dead:
		return

	if is_teleporting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if global_position.y > fall_limit_y:
		die()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and can_jump and Input.is_action_just_pressed("ui_up"):
		velocity.y = -sqrt(2 * gravity * jump_height)
		Audio.play("jump")

	if Input.is_action_just_pressed("color_1") and 0 in allowed_colors:
		current_color = 0
	if Input.is_action_just_pressed("color_2") and 1 in allowed_colors:
		current_color = 1
	if Input.is_action_just_pressed("color_3") and 2 in allowed_colors:
		current_color = 2
	if Input.is_action_just_pressed("color_4") and 3 in allowed_colors:
		# ungu cuma boleh 1 pasang (2 tile). Begitu pasangan lengkap,
		# ungu gak bisa dipilih lagi -- kedua tile pasangannya juga
		# udah dikunci total di shoot_paint() (lihat _is_purple_pair_locked).
		if _purple_paint_count() >= 2:
			current_color = 0
		else:
			current_color = 3

	GameState.current_color = current_color

	if is_painting:
		velocity.x = 0
		move_and_slide()
		_check_landing()
		return

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		sprite.flip_h = direction < 0
		if sprite.animation != "Walk":
			sprite.play("Walk")
	else:
		if sprite.animation != "Idle":
			sprite.play("Idle")

	velocity.x = direction * speed
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)

		if collision.get_collider() == spike_tilemap:
			die()

	var rect := _get_shape_global_rect()

	if is_on_floor():
		var new_vel_y = HazardSystem.check_trampoline(
			tilemap, rect, gravity, bounce_height, velocity.y
		)
		if new_vel_y != velocity.y:
			Audio.play("bounce")
		velocity.y = new_vel_y

	#if HazardSystem.check_spike(spike_tilemap, rect):
		#die()

	_check_landing()
	check_teleport()

func _check_landing() -> void:
	var on_floor_now := is_on_floor()
	if on_floor_now and not _was_on_floor:
		Audio.play("tkss")
	_was_on_floor = on_floor_now

func _get_shape_global_rect() -> Rect2:
	var size := Vector2(16, 16)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		size = (collision_shape.shape as RectangleShape2D).size
	var shape_center: Vector2 = global_position + collision_shape.position
	var top_left: Vector2 = shape_center - size / 2.0
	return Rect2(top_left, size)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	Audio.play("dead")
	var tween = create_tween()
	for i in range(5):
		tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.tween_callback(_do_respawn)

func _do_respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	sprite.modulate.a = 1.0
	sprite.play("Idle")
	is_dead = false

# Dipanggil dari _unhandled_input, bukan polling lagi -- biar konsisten
# sama shoot_paint (gak ke-trigger kalau klik/E ketangkep UI duluan).
func _try_interact() -> void:
	if decor_tilemap == null:
		return

	var check_position := global_position + Vector2(0, 16)
	var cell := decor_tilemap.local_to_map(decor_tilemap.to_local(check_position))
	var tile_data := decor_tilemap.get_cell_tile_data(cell)

	if tile_data == null:
		return

	var target_scene = tile_data.get_custom_data("portal")

	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)

func _on_animation_finished() -> void:
	if sprite.animation == "Paint":
		is_painting = false
		sprite.play("Idle")

func shoot_paint(target_pos: Vector2) -> void:
	is_painting = true
	sprite.play("Paint")

	var to_target = target_pos - global_position
	var distance = min(to_target.length(), shoot_range)
	var direction = to_target.normalized()
	var final_pos = global_position + direction * distance
	var cell = tilemap.local_to_map(tilemap.to_local(final_pos))

	var state = _get_level_state()
	var tiles: Dictionary = state["tiles"]

	# pair ungu udah lengkap (2 tile) & cell ini salah satunya -> dikunci
	# total, gak bisa dicat ulang jadi warna apapun.
	if _is_purple_pair_locked(tiles, cell):
		return

	if current_color == 3 and not _can_paint_purple(tiles, cell):
		# udah ada 1 pasang ungu aktif di level ini -> gak bisa ngecat
		# tile BARU jadi ungu sampai pasangan itu dibongkar (salah satu
		# tilenya dicat ulang jadi warna lain).
		return

	var painted := PaintSystem.paint_one(tilemap, cell, current_color, color_lookup)
	if not painted:
		# gak ada tile di cell itu / kombinasi warna gak ada di tileset ->
		# gak ada yang berubah secara visual, jangan catat apa-apa ke state.
		return

# Ungu (color id 3) cuma boleh ada 1 pasang (maksimal 2 tile) sekaligus
# per level.
func _can_paint_purple(tiles: Dictionary, cell: Vector2i) -> bool:
	# recolor tile yang emang udah ungu selalu "boleh" secara hitungan
	# (gak nambah count baru) -- tapi kalau pair udah lengkap, fungsi ini
	# gak akan kepanggil sama sekali karena _is_purple_pair_locked udah
	# nolak duluan di shoot_paint().
	if tiles.get(cell, -1) == 3:
		return true
	return _purple_paint_count() < 2

# Begitu pasangan ungu (2 tile) udah lengkap, KEDUA tile itu dikunci
# total -- gak bisa dicat ulang jadi warna apapun lagi (termasuk dicat
# ungu ulang). Ini yang bikin pasangan permanen begitu terbentuk.
func _is_purple_pair_locked(tiles: Dictionary, cell: Vector2i) -> bool:
	return tiles.get(cell, -1) == 3 and _purple_paint_count() >= 2

# --- TELEPORT (warna ungu / color id 3) ---
func check_teleport() -> void:
	if tilemap == null or is_teleporting:
		return

	var state = _get_level_state()
	var tiles: Dictionary = state.get("tiles", {})

	var hit_cell = null
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == tilemap:
			var cell: Vector2i = tilemap.local_to_map(tilemap.to_local(collision.get_position()))
			if tiles.get(cell, -1) == 3:
				hit_cell = cell
				break

	if hit_cell == null:
		_on_teleport_tile = false
		return

	if _on_teleport_tile and hit_cell == _current_teleport_cell:
		return

	var target_cell = null
	for painted_cell in tiles.keys():
		if painted_cell != hit_cell and tiles[painted_cell] == 3:
			target_cell = painted_cell
			break

	if target_cell == null:
		_on_teleport_tile = false
		return

	state["teleport_used"] = true

	_on_teleport_tile = true
	_current_teleport_cell = target_cell
	_start_teleport(target_cell)

func _start_teleport(cell: Vector2i) -> void:
	is_teleporting = true
	velocity = Vector2.ZERO

	await get_tree().create_timer(teleport_pre_delay).timeout
	teleport_to(cell)
	await get_tree().create_timer(teleport_post_delay).timeout

	is_teleporting = false

func teleport_to(cell: Vector2i) -> void:
	var target_pos: Vector2 = tilemap.to_global(tilemap.map_to_local(cell))
	global_position = target_pos + Vector2(0, -8)
	velocity = Vector2.ZERO
	Audio.play("teleport")
