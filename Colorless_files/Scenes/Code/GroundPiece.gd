extends Sprite2D

var is_being_sucked := false
var blackhole: Node2D
var start_pos: Vector2
var start_distance: float
var start_angle: float
var elapsed := 0.0
var duration := 1.4
var spiral_turns := 2.0

func start_suck(target: Node2D, delay: float = 0.0):
	blackhole = target
	start_pos = global_position
	start_distance = start_pos.distance_to(blackhole.global_position)
	start_angle = (start_pos - blackhole.global_position).angle()
	await get_tree().create_timer(delay).timeout
	is_being_sucked = true

func _process(delta):
	if not is_being_sucked or not is_instance_valid(blackhole):
		return
	elapsed += delta
	var t = clamp(elapsed / duration, 0.0, 1.0)
	var ease_t = ease(t, 0.4)
	var current_distance = lerp(start_distance, 0.0, ease_t)
	var current_angle = start_angle + ease_t * spiral_turns * TAU
	var offset = Vector2(cos(current_angle), sin(current_angle)) * current_distance
	global_position = blackhole.global_position + offset
	scale = Vector2.ONE * (1.0 - ease_t)
	rotation += delta * 6.0 * ease_t
	if t >= 1.0:
		queue_free()
