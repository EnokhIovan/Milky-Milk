extends CharacterBody2D

# Kecepatan jalan karakter
@export var speed: float = 200.0

func _physics_process(_delta):
	# Mengambil input dari tombol arah (Arrow keys / WASD)
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Mengatur kecepatan (velocity) berdasarkan arah input
	velocity = input_direction * speed

	# Mengeksekusi pergerakan (sudah menangani tabrakan dengan tembok)
	move_and_slide()
