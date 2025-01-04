extends Node2D

@onready var happiness_bar = $CanvasLayer/TopBar/HBoxContainer/HappyBar
@onready var hunger_bar = $CanvasLayer/TopBar/HBoxContainer/FoodBar
@onready var health_bar = $CanvasLayer/TopBar/HBoxContainer/HealthBar
@onready var energy_bar = $CanvasLayer/TopBar/HBoxContainer/EnergyBar

@onready var food_btn = $CanvasLayer/HBoxContainer/FoodBtn
@onready var shower_btn = $CanvasLayer/HBoxContainer/ShowerBtn
@onready var play_btn = $CanvasLayer/HBoxContainer/PlayBtn
@onready var sleep_btn = $CanvasLayer/HBoxContainer/SleepBtn
@onready var garage_btn = $CanvasLayer/HBoxContainer/GarageBtn

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

func _ready():
	for name in buttons:
		buttons[name].connect("pressed", Callable(self, "_on_button_pressed").bind(name))

	# Start with "play" as the default active button
	_set_default_active("play")

func _set_default_active(gui_name: String):
	active_button = buttons[gui_name]
	active_button.disabled = true
	_on_button_pressed(gui_name)

func _on_button_pressed(gui_name: String):
	print("Pressed:", gui_name.capitalize(), "Button")

	# Toggle GUI visibility
	for name in guis:
		guis[name].visible = (name == gui_name)

	# Re-enable previously active button
	if active_button and active_button != buttons[gui_name]:
		active_button.disabled = false

	# Disable the new active button
	active_button = buttons[gui_name]
	active_button.disabled = true
