extends CanvasLayer

@onready var punishment_label: Label = $Punishment
@onready var notice_label: Label = $Notice

var _sfx: Dictionary = {}
var _notice_timer: Timer

func _ready():
	hud.visible = false
	# main.tscn instances its own HUD, so the autoload only keeps its popups and sounds.
	if self == hud:
		for gameplay_node in [$InventoryBG, $Control, $Inventory, $Crosshair, $Key]:
			gameplay_node.visible = false
	_add_sfx("collect", "res://Assets/Audio/collect.mp3", 0.0)
	_add_sfx("caught", "res://Assets/Audio/caught.mp3", -6.0)
	_add_sfx("win", "res://Assets/Audio/win.mp3", -6.0)
	_add_sfx("defeat", "res://Assets/Audio/defeat.mp3", -6.0)
	_add_sfx("door", "res://Assets/Audio/door.mp3", -2.0)

	_notice_timer = Timer.new()
	_notice_timer.one_shot = true
	_notice_timer.timeout.connect(_on_notice_timeout)
	add_child(_notice_timer)

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

func play_door() -> void:
	_play_sfx("door")


func show_punishment_label(time_left: float) -> void:
	visible = true
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

func show_notice(message: String, duration: float = 2.0) -> void:
	visible = true
	notice_label.text = message
	notice_label.visible = true
	_notice_timer.start(duration)

func _on_notice_timeout() -> void:
	notice_label.visible = false
