extends Node

var sfx: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player := 0

const SFX_FOLDERS := {
	"bounce": "res://Colorless_files/Sound/SFX/Jumping/Bounce/",
	"paint": "res://Colorless_files/Sound/SFX/Painting/",
	"walk_cape": "res://Colorless_files/Sound/SFX/Walking/Cape/",
	"walk_mud": "res://Colorless_files/Sound/SFX/Walking/Mud/",
}
const SINGLE_FILES := {
	"landing": "res://Colorless_files/Sound/SFX/Landing.wav",
	"jump": "res://Colorless_files/Sound/SFX/Jumping/Twing Jump.wav",
}

func _ready() -> void:
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

	for key in SFX_FOLDERS:
		sfx[key] = _load_variants(SFX_FOLDERS[key])
	for key in SINGLE_FILES:
		var stream = load(SINGLE_FILES[key])
		sfx[key] = [stream] if stream else []

func _load_variants(path: String) -> Array:
	var arr := []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Folder gak ketemu: %s" % path)
		return arr
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if f.ends_with(".wav") and not f.ends_with(".import"):
			arr.append(load(path.path_join(f)))
		f = dir.get_next()
	dir.list_dir_end()
	return arr

func play(key: String, pitch_variance := 0.05) -> void:
	if not sfx.has(key) or sfx[key].is_empty():
		push_warning("Sound '%s' kosong / belum ke-load" % key)
		return
	var variants: Array = sfx[key]
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	player.stream = variants[randi() % variants.size()]
	player.play()
