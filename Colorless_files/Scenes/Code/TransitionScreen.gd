extends CanvasLayer
signal _on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var h_container = $HBoxContainer
@onready var loading_text = h_container.get_node("LoadingText")
@onready var texture_rect = h_container.get_node("TextureRect")
@onready var timer = $Timer

# ganti path ini sesuai lokasi frame-frame kamu
const LOADING_FRAMES := [
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/1.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/2.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/3.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/4.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/5.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/6.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/7.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/8.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/9.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/10.png",
	"res://Colorless_files/Art/Icon/Loading/Loading - Anim/11.png",
]

func _ready():
	color_rect.visible = false
	h_container.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	_setup_loading_animation()

func _setup_loading_animation() -> void:
	var anim_tex := AnimatedTexture.new()
	anim_tex.frames = LOADING_FRAMES.size()  # WAJIB set dulu sebelum assign per-frame

	for i in range(LOADING_FRAMES.size()):
		var tex: Texture2D = load(LOADING_FRAMES[i])
		if tex == null:
			push_warning("Frame %d gagal di-load: %s" % [i, LOADING_FRAMES[i]])
			continue
		anim_tex.set_frame_texture(i, tex)
		anim_tex.set_frame_duration(i, 0.1)  # delay per frame (detik), atur sesuai kebutuhan

	texture_rect.texture = anim_tex

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_dark":
		h_container.visible = true
		timer.start(2.0)
		await timer.timeout
		
		h_container.visible = false
		_on_transition_finished.emit()
		animation_player.play("fade_dark_to_normal")
	elif anim_name == "fade_dark_to_normal":
		color_rect.visible = false

func transition(animation: String):
	color_rect.visible = true
	animation_player.play(animation)
