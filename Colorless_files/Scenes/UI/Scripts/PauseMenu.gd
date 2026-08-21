extends CanvasLayer

@export var main_menu_scene: PackedScene
@export var select_level_scene: PackedScene

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$MenuGroup.visible = false
	$Pause.pressed.connect(toggle_pause)
	$MenuGroup/PauseCanvas/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$MenuGroup/PauseCanvas/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$MenuGroup/PauseCanvas/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)
	$MenuGroup/PauseCanvas/VBoxContainer/SelectLevel.pressed.connect(_on_select_level_pressed)	

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	$MenuGroup.visible = get_tree().paused

func _on_resume_pressed():
	toggle_pause()

func _on_restart_pressed():
	get_tree().paused = false

	var level_id: String = GameState.current_level_id
	if level_id == "":
		push_warning("GameState.current_level_id kosong, progress gak direset!")
	else:
		PaintSystem.reset_progress(level_id)

	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	if main_menu_scene == null:
		push_warning("Main Menu Scene belum di-assign di Inspector!")
		return
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_select_level_pressed():
	if select_level_scene == null:
		push_warning("Select Level Scene belum di-assign di Inspector!")
		return
	get_tree().paused = false
	get_tree().change_scene_to_packed(select_level_scene)
