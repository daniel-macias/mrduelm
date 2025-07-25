extends Node2D

@onready var fun_bar = $CanvasLayer/TopBar/HBoxContainer/HappyBar
@onready var hunger_bar = $CanvasLayer/TopBar/HBoxContainer/FoodBar
@onready var health_bar = $CanvasLayer/TopBar/HBoxContainer/HealthBar
@onready var energy_bar = $CanvasLayer/TopBar/HBoxContainer/EnergyBar

@onready var food_btn = $CanvasLayer/HBoxContainer/FoodBtn
@onready var shower_btn = $CanvasLayer/HBoxContainer/ShowerBtn
@onready var play_btn = $CanvasLayer/HBoxContainer/PlayBtn
@onready var sleep_btn = $CanvasLayer/HBoxContainer/SleepBtn
@onready var garage_btn = $CanvasLayer/HBoxContainer/GarageBtn

@onready var pet = $Camera2D/Pet

@onready var money_lbl = $CanvasLayer/TopBar/Label
@onready var level_lbl = $CanvasLayer/TopBar/Level/LevelLabel

@onready var loading_bg = $Outside/LoadingBG
@onready var loading_anim = $Outside/LoadingBG/AnimationPlayer

@onready var dialog = $Outside/Dialog

@onready var guis = {
	"food": $CanvasLayer/FoodGUI,
	"bathroom": $CanvasLayer/BathroomGUI,
	"play": $CanvasLayer/PlayGUI,
	"sleep": $CanvasLayer/SleepGUI,
	"garage": $CanvasLayer/GarageGUI
}

@onready var buttons = {
	"food": food_btn,
	"bathroom": shower_btn,
	"play": play_btn,
	"sleep": sleep_btn,
	"garage": garage_btn
}

var active_button = null

@onready var loading_ar_lbl : Label = $Outside/LoadingBG/LoadingCat/Label

@onready var sleep_gui = $CanvasLayer/SleepGUI #I know it is repetitive

func _ready():
	
	GameManager.connect("stat_changed", Callable(self, "_on_stat_changed"))
	GameManager.connect("money_changed", Callable(self, "_on_money_changed"))
	GameManager.connect("level_changed", Callable(self, "_on_level_changed"))

	money_lbl.text = str(GameManager.player_money)
	level_lbl.text = str(GameManager.level)
	loading_ar_lbl.text = tr("LOADING_AR_DESC")
	
	for name in buttons:
		buttons[name].connect("pressed", Callable(self, "_on_button_pressed").bind(name))

	# Start with "play" as the default active button
	_set_default_active("play")
	
	$Outside/ClothesInventory.connect("pet_needs_update", Callable(self, "_update_pet_equipment"))
	
	_on_stat_changed("fun", GameManager.fun)
	_on_stat_changed("hunger", GameManager.hunger)
	_on_stat_changed("health", GameManager.health)
	_on_stat_changed("energy", GameManager.energy)
	
	_update_pet_equipment()
	
	if TutorialManager.get_current_step_id() == "INITIAL_GAME":
		loading_bg.visible = true
		loading_anim.play("LoadingOut")
		loading_anim.animation_finished.connect(_on_loading_out_finished)
	else:
		loading_bg.queue_free()
	
func _on_stat_changed(stat_name: String, new_value: int):
	match stat_name:
		"fun":
			fun_bar.value = new_value
		"hunger":
			hunger_bar.value = new_value
		"health":
			health_bar.value = new_value
		"energy":
			energy_bar.value = new_value

func _on_debug_add_food_btn():
	GameManager.modify_stat("hunger", 10)

func _on_debug_add_health_btn():
	GameManager.modify_stat("health", 10)

func _set_default_active(gui_name: String):
	active_button = buttons[gui_name]
	active_button.disabled = true
	_on_button_pressed(gui_name)

func _on_button_pressed(gui_name: String):
	print("Pressed:", gui_name.capitalize(), "Button")
	GameManager.current_room = gui_name.capitalize()
	sleep_gui.disconnect_cable_for_signal()

	# Toggle GUI visibility
	for name in guis:
		guis[name].visible = (name == gui_name)

	# Re-enable previously active button
	if active_button and active_button != buttons[gui_name]:
		active_button.disabled = false

	# Disable the new active button
	active_button = buttons[gui_name]
	active_button.disabled = true

func _update_pet_equipment():
	pet.change_part_appearance(GameManager.equipped["arm"])
	pet.change_part_appearance(GameManager.equipped["leg"])
	pet.change_part_appearance(GameManager.equipped["body"])

func _on_money_changed(new_amount):
	money_lbl.text = str(new_amount)

func _on_level_changed(new_amount):
	level_lbl.text = str(new_amount)
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		GameManager.save_game()
		
func _on_loading_out_finished(anim_name: String):
	if anim_name == "LoadingOut":
		loading_bg.queue_free()
		dialog.show_dialog(tr("WELCOME_MSG_TITLE"), tr("WELCOME_MSG_MSG"), true)
