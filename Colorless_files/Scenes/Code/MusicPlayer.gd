extends Node

const TRACKS := {
	"main": "res://Colorless_files/Sound/Pijar Kelabu/Pijar Kelabu BGM.wav",
	"raining": "res://Colorless_files/Sound/Pijar Kelabu/Pijar Kelabu BGM - Raining.wav",
	"harmoni": "res://Colorless_files/Sound/Pijar Kelabu/Pijar Kelabu - Harmoni.wav",
}
const FADE_TIME := 1.5

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _current_track := ""

func _ready() -> void:
	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	add_child(_player_a)
	add_child(_player_b)
	_active_player = _player_a

func play(track_key: String, fade := true) -> void:
	if not TRACKS.has(track_key):
		push_warning("Track '%s' gak ada di TRACKS" % track_key)
		return
	if track_key == _current_track:
		return

	var stream = load(TRACKS[track_key])
	if stream == null:
		push_warning("Gagal load: %s" % TRACKS[track_key])
		return

	var old_player := _active_player
	var next_player := _player_b if _active_player == _player_a else _player_a

	next_player.stream = stream
	next_player.volume_db = -80 if fade else 0
	next_player.play()
	_active_player = next_player
	_current_track = track_key

	if fade:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(next_player, "volume_db", 0.0, FADE_TIME)
		tween.tween_property(old_player, "volume_db", -80.0, FADE_TIME)
		tween.chain().tween_callback(old_player.stop)
	else:
		old_player.stop()

func stop(fade := true) -> void:
	if fade:
		var tween := create_tween()
		tween.tween_property(_active_player, "volume_db", -80.0, FADE_TIME)
		tween.tween_callback(_active_player.stop)
	else:
		_active_player.stop()
	_current_track = ""
