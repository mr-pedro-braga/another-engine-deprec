extends Node

var hearts_in_sync = preload("res://assets/music/mus_hearts_in_bits.wav")
var test_music = hearts_in_sync #load("res://assets/music/mus_uncanny_valley.wav")
var harmony_hall = preload("res://assets/music/mus_harmony_hall.wav")

var music_cache = {}

var battle_music_switch = true
var bgm_player: AudioStreamPlayer
var battle_m_player: AudioStreamPlayer
var current_BGM = "Hearts in Sync"

func get_current_music():
	return bgm_player.stream

func load_music_from_stream(stream):
	bgm_pause()
	bgm_player.stream = stream

func setup_stream_players():
	bgm_player = get_node("/root/GameRoot/BGM")
	battle_m_player = get_node("/root/GameRoot/BattleTheme")

func clear_cache():
	music_cache.clear()

func preload_music(file):
	music_cache["file"] = load("res://assets/music/" + file)

func load_battle_music(file):
	print("Loading ", file, " as battle music!")
	if music_cache.has(file):
		battle_m_player.stream = music_cache["file"]
		return
	battle_m_player.stream = load("res://assets/music/" + file)

var music_loaded:bool = false

func unload_music():
	bgm_pause()
	music_loaded = false
	current_BGM = ""

func load_music(file, display_name):
	music_loaded = true
	print("Loading ", display_name)
	if display_name == current_BGM:
		return
	current_BGM = display_name
	if music_cache.has(file):
		bgm_player.stream = music_cache["file"]
		return
	bgm_player.stream = load("res://assets/music/" + file)

func bgm_restart():
	if music_loaded:
		bgm_player.play(0.0)

func bgm_resume():
	if music_loaded:
		bgm_player.playing = true

func bgm_pause():
	bgm_player.playing = false
