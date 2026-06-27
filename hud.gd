extends CanvasLayer

@onready var punishment_label: Label = $Punishment

var _sfx: Dictionary = {}

func _ready():
	hud.visible = false
	_add_sfx("collect", "res://collect.mp3", -8.0)
	_add_sfx("caught", "res://caught.mp3", -6.0)
	_add_sfx("win", "res://win.mp3", -6.0)
	_add_sfx("defeat", "res://defeat.mp3", -6.0)

func _add_sfx(key: String, path: String, volume_db: float) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.volume_db = volume_db
	add_child(player)
	_sfx[key] = player

func _play_sfx(key: String) -> void:
	if _sfx.has(key):
		_sfx[key].play()

func play_collect() -> void:
	_play_sfx("collect")

func play_caught() -> void:
	_play_sfx("caught")

func play_win() -> void:
	_play_sfx("win")

func play_defeat() -> void:
	_play_sfx("defeat")


func show_punishment_label(time_left: float) -> void:
	_set_punishment_text(time_left)
	punishment_label.visible = true

func update_punishment_label(time_left: float) -> void:
	_set_punishment_text(time_left)

func _set_punishment_text(time_left: float) -> void:
	var seconds_left: int = int(ceil(time_left))
	var unit := "second" if seconds_left == 1 else "seconds"
	punishment_label.text = "You were caught! You can move again in %d %s." % [seconds_left, unit]

func hide_punishment_label() -> void:
	punishment_label.visible = false
