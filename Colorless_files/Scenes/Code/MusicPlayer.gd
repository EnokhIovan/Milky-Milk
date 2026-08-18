extends Node
const TRACKS := {
	"raining": "res://Colorless_files/Sound/Musik/Pijar Kelabu/Pijar Kelabu BGM - Raining.wav",
	"harmoni": "res://Colorless_files/Sound/Musik/Pijar Kelabu/Pijar Kelabu - Harmoni.wav",
	"homescreen": "res://Colorless_files/Sound/Musik/Melodi Chromata.wav",
	"bgm-aura_prisma": "res://Colorless_files/Sound/Musik/Aura Prisma BGM.wav"
}
const FADE_TIME := 1.5
var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _current_track := ""
var _tween: Tween
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
	if _tween and _tween.is_valid():
		_tween.kill()
	_apply_loop(stream)
	var old_player := _active_player
	var next_player := _player_b if _active_player == _player_a else _player_a
	next_player.stream = stream
	next_player.volume_db = -80 if fade else 0
	next_player.play()
	_active_player = next_player
	_current_track = track_key
	if fade:
		_tween = create_tween()
		_tween.set_parallel(true)
		_tween.tween_property(next_player, "volume_db", 0.0, FADE_TIME)
		_tween.tween_property(old_player, "volume_db", -80.0, FADE_TIME)
		_tween.chain().tween_callback(old_player.stop)
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
func _apply_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		# loop_end HARUS di-set ke total sample; kalau dibiarkan 0
		# (default file yang loop mode-nya "Detect From" tanpa metadata loop),
		# playback akan dianggap "selesai" instan alih-alih looping
		if stream.loop_end <= stream.loop_begin:
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
