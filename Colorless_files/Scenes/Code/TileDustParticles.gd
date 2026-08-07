extends GPUParticles2D

func _ready() -> void:
	finished.connect(queue_free)

func burst() -> void:
	emitting = true
