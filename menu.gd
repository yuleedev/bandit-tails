extends Control

var music: AudioStreamPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_start_music()

# Looping menu music. Lives under this scene so it stops when we leave the menu.
func _start_music() -> void:
	music = AudioStreamPlayer.new()
	var stream := load("res://menu.mp3")
	if stream is AudioStreamMP3:
		stream.loop = true
	music.stream = stream
	music.volume_db = -12.0
	add_child(music)
	music.play()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/hostjoin.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial.tscn")
