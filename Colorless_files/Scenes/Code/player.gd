extends CharacterBody2D
@export var speed := 150.0
@export var shoot_range := 300.0
@export var gravity := 800.0
@export var jump_height := 32.0
@export var bounce_height := 64.0
@export var fall_limit_y := 672.0
@export var tilemap_path: NodePath
@export var spike_tilemap_path: NodePath
var is_painting := false
var is_dead := false
var current_color := 0
var spawn_position: Vector2
var grid_cols := 0
var grid_rows := 0
var _was_on_floor := true
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var tilemap: TileMapLayer = get_node(tilemap_path)
@onready var spike_tilemap: TileMapLayer = get_node(spike_tilemap_path)

func _ready():
	MusicPlayer.play("main")
	add_to_group("player")
	sprite.animation_finished.connect(_on_animation_finished)
	var grid = PaintSystem.calculate_grid_size(tilemap)
	grid_cols = grid.x
	grid_rows = grid.y
	sprite.play("Idle")
	spawn_position = global_position
	_was_on_floor = is_on_floor()

func _physics_process(delta):
	if is_dead:
		return
	if global_position.y > fall_limit_y:
		die()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = -sqrt(2 * gravity * jump_height)
		Audio.play("jump")

	if Input.is_action_just_pressed("color_1"):
		current_color = 0
	if Input.is_action_just_pressed("color_2"):
		current_color = 1
	if Input.is_action_just_pressed("color_3"):
		current_color = 2
	if Input.is_action_just_pressed("paint"):
		shoot_paint(get_global_mouse_position())
		Audio.play("paint")

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

	var rect := _get_shape_global_rect()
	if is_on_floor():
		var new_vel_y = HazardSystem.check_trampoline(
			tilemap, rect, gravity, bounce_height, velocity.y, grid_cols, grid_rows
		)
		if new_vel_y != velocity.y:
			Audio.play("bounce")
		velocity.y = new_vel_y

	if HazardSystem.check_spike(spike_tilemap, rect):
		die()

	_check_landing()

func _check_landing() -> void:
	var on_floor_now := is_on_floor()
	if on_floor_now and not _was_on_floor:
		Audio.play("landing")
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
	PaintSystem.paint_one(tilemap, cell, current_color, grid_cols, grid_rows)
