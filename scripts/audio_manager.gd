extends Node
# Audio manager, registered as the autoload "Audio".
# An autoload is created once when the game starts and is NOT deleted when
# a scene reloads, so the music keeps playing smoothly after every death.
# Any script can call it directly, e.g. Audio.play("jump").

const SOUNDS := {
	"jump": preload("res://audio/jump.wav"),
	"death": preload("res://audio/death.wav"),
	"fall": preload("res://audio/fall.wav"),
	"coin": preload("res://audio/coin.wav"),
	"goal": preload("res://audio/goal.wav"),
}
const MUSIC := preload("res://audio/music.wav")
const POOL_SIZE := 8              # up to 8 sound effects can overlap
const MUSIC_VOLUME := -10.0       # music quieter than effects
const MUSIC_SILENT := -40.0

var _pool: Array[AudioStreamPlayer] = []
var _next: int = 0
var _music: AudioStreamPlayer
var _music_tween: Tween


func _ready() -> void:
	# Pool of players, reused in turn, instead of creating a new node per sound.
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)

	_music = AudioStreamPlayer.new()
	_music.stream = MUSIC
	_music.volume_db = MUSIC_VOLUME
	add_child(_music)
	_music.finished.connect(_music.play)   # loop: start again when it ends
	_music.play()


# pitch_variation = random pitch change, so repeated sounds don't feel robotic.
func play(sound: String, volume_db: float = 0.0, pitch_variation: float = 0.0) -> void:
	var p := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = SOUNDS[sound]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	p.play()


# Smoothly fade the music down (falling into a pit) or back up (restart).
func set_music_ducked(ducked: bool, seconds: float = 0.8) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	var target := MUSIC_SILENT if ducked else MUSIC_VOLUME
	_music_tween.tween_property(_music, "volume_db", target, seconds)
