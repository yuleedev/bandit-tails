extends Node

## ================ [ FIELDS ] ================ ##

@export var options: Options = Options.new()
@export var ROUND_DURATION: float = 60
var loot_spawner: Node = null

var round: int = 1
var round_dur: float = 0
var game_paused: bool = true
var mouse_captured: bool = false
var p1_keys = 0
var p2_keys = 0
var p1_id: int = 1
var p2_id: int

var p1_round_value: float
var p2_round_value: float
var p1_total_value: float = 0
var p2_total_value: float = 0

var p1_wins: float = 0
var p2_wins: float = 0

## ================ [ METHODS ] ================ ##
@rpc("call_local")
func select_char() -> void:
	get_tree().change_scene_to_file("res://character_select.tscn")

@rpc("call_local")
func start_game() -> void:
	stop_menu_music()
	get_tree().change_scene_to_file("res://Levels/main.tscn")
	hud.visible = true
	await get_tree().process_frame

@rpc("call_local")
func show_result_screen(result: String) -> void:
	match result:
		"host":
			if multiplayer.is_server():
				hud.play_win()
			else:
				hud.play_defeat()
			get_tree().change_scene_to_file("res://hostwin.tscn")
		"joiner":
			if multiplayer.is_server():
				hud.play_defeat()
			else:
				hud.play_win()
			get_tree().change_scene_to_file("res://joinerwin.tscn")
		"tie":
			hud.play_defeat()
			get_tree().change_scene_to_file("res://tie.tscn")

@rpc("call_local")
func end_game() -> void:
	game_paused = true

	if p1_wins > p2_wins:
		show_result_screen.rpc("host")
	elif p2_wins > p1_wins:
		show_result_screen.rpc("joiner")
	else:
		show_result_screen.rpc("tie")

@rpc("any_peer", "call_local")
func new_round() -> void:
	
	p1_round_value = 0
	p2_round_value = 0
	p1_keys = 0
	p2_keys = 0
	
	await get_tree().process_frame
	print("awaited")
	if get_tree().current_scene.scene_file_path != "res://Levels/main.tscn":
		get_tree().change_scene_to_file("res://Levels/main.tscn")

	hud.visible = true
	round_dur = ROUND_DURATION
	game_paused = false

@rpc
func end_round() -> void:
	game_paused = true
	hud.visible = false
	
	print("p1's total val: " + str(p1_round_value))
	print("p2's total val: " + str(p2_round_value))
	p1_total_value += p1_round_value
	p2_total_value += p2_round_value
	
	if p1_round_value > p2_round_value:
		p1_wins += 1
	if p2_round_value > p1_round_value:
		p2_wins += 1
	else: 
		pass
	
	
	if round < 3:
		get_tree().change_scene_to_file("res://postround.tscn")
	else:
		end_game()

var menu_music: AudioStreamPlayer

func play_menu_music() -> void:
	if menu_music == null:
		menu_music = AudioStreamPlayer.new()
		var stream := load("res://menu.mp3")
		if stream is AudioStreamMP3:
			stream.loop = true
		menu_music.stream = stream
		menu_music.volume_db = -12.0
		add_child(menu_music)
	if not menu_music.playing:
		menu_music.play()

func stop_menu_music() -> void:
	if menu_music and menu_music.playing:
		menu_music.stop()

var ui_hover: AudioStreamPlayer
var ui_click: AudioStreamPlayer

func play_ui_hover() -> void:
	if ui_hover == null:
		ui_hover = AudioStreamPlayer.new()
		ui_hover.stream = load("res://hover.mp3")
		ui_hover.volume_db = -12.0
		add_child(ui_hover)
	ui_hover.play()

func play_ui_click() -> void:
	if ui_click == null:
		ui_click = AudioStreamPlayer.new()
		ui_click.stream = load("res://click.mp3")
		ui_click.volume_db = -8.0
		add_child(ui_click)
	ui_click.play()

func wire_ui_sounds(root: Node) -> void:
	if root == null:
		return
	var buttons := root.find_children("*", "BaseButton", true, false)
	if root is BaseButton:
		buttons.append(root)
	for button in buttons:
		if not button.mouse_entered.is_connected(play_ui_hover):
			button.mouse_entered.connect(play_ui_hover)
		if not button.pressed.is_connected(play_ui_click):
			button.pressed.connect(play_ui_click)

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

## ================ [ GODOT ] ================ ##

func _process(delta: float) -> void:
	if not game_paused:
		round_dur -= delta
	
		if round_dur <= 0:
			end_round()

func _input(event: InputEvent) -> void:
	if event.is_action("escape") and event.is_pressed():
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()
