extends Node

var music_player: AudioStreamPlayer
var current_track: String = ""

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

func play_music(track_path: String):
	if current_track == track_path and music_player.playing:
		return  # Already playing this track

	current_track = track_path
	var stream = load(track_path)
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
	current_track = ""

func _on_music_finished():
	# Loop the music
	if current_track != "":
		music_player.play()
