extends Area2D

@export var pull_strength: float = 1000.0   # seberapa kuat tarikannya
@export var active: bool = true           # cuma narik kalau blackhole udah aktif

var bodies_in_field: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies_in_field.append(body)

func _on_body_exited(body: Node2D) -> void:
	bodies_in_field.erase(body)

func _physics_process(delta: float) -> void:
	if not active:
		return
	for body in bodies_in_field:
		if not is_instance_valid(body):
			continue
		var dx = global_position.x - body.global_position.x
		var distance = abs(dx)
		var direction_x = sign(dx)  # -1 kiri, 1 kanan, 0 kalau pas sejajar
		var falloff = clamp(1.0 - (distance / get_field_radius()), 0.0, 1.0)
		
		if body is CharacterBody2D:
			body.velocity.x += direction_x * pull_strength * falloff * delta * 60.0

func get_field_radius() -> float:
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		return shape.radius
	return 200.0  # fallback
