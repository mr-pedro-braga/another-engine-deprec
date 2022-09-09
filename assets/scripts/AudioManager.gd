extends Node

func play_sound(sound:String, ext:String = "wav"):
	play_audio(AudioType.NON_POSITIONAL, self, sound, 0.0, 1.0, ext)

# Audio
enum AudioType {
	NON_POSITIONAL,
	POSITIONAL_2D,
}

func play(name:String, volume:float = 0.0, ext = "wav"):
	play_audio(AudioType.NON_POSITIONAL, get_node("/root/GameRoot/"), name, volume, 1.0, ext)

var audio_cache := {}
func play_audio(type: int, parent: Node, file: String, volume_db: float = 0.0, pitch_scale: float = 1.0, ext = "wav") -> void:
	var audio_stream_player: Node
	match type:
		AudioType.NON_POSITIONAL:
			audio_stream_player = AudioStreamPlayer.new()
		AudioType.POSITIONAL_2D:
			audio_stream_player = AudioStreamPlayer2D.new()
	parent.add_child(audio_stream_player)
	audio_stream_player.bus = "SFX"
	if not audio_cache.has(file):
		audio_cache[file] = load("res://assets/sounds/" + file + "." + ext)
	audio_stream_player.stream = audio_cache[file]
	audio_stream_player.volume_db = volume_db
	audio_stream_player.pitch_scale = pitch_scale
	audio_stream_player.play()
	audio_stream_player.connect("finished", audio_stream_player, "queue_free")
