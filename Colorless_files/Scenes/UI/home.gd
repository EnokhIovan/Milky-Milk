extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var start_btn: TextureButton = $Start
@onready var option_btn: TextureButton = $Option
@onready var exit_btn: TextureButton = $Exit

var _original_positions := {}

func _ready() -> void:
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.6)

	MusicPlayer.play("raining")

	_setup_press_effect(start_btn)
	_setup_press_effect(option_btn)
	_setup_press_effect(exit_btn)

func _setup_press_effect(btn: TextureButton) -> void:
	_original_positions[btn] = btn.position
	btn.button_down.connect(_on_button_down.bind(btn))
	btn.button_up.connect(_on_button_up.bind(btn))

func _on_button_down(btn: TextureButton) -> void:
	var target: Vector2 = _original_positions[btn] + Vector2(-6, -6)
	var tween := create_tween()
	tween.tween_property(btn, "position", target, 0.1)

func _on_button_up(btn: TextureButton) -> void:
	var target: Vector2 = _original_positions[btn]
	var tween := create_tween()
	tween.tween_property(btn, "position", target, 0.1)

func _on_start_pressed() -> void:
	await fade_to_black()
	get_tree().change_scene_to_file("res://Colorless_files/Scenes/Levels/level_1.tscn")

func _on_option_pressed() -> void:
	print("buka panel options nanti")

func _on_exit_pressed() -> void:
	await fade_to_black()
	get_tree().quit()

func fade_to_black() -> void:
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)
	await tween.finished
