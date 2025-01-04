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

func _ready():
	food_btn.connect("pressed", Callable(self, "_on_button_pressed").bind("food"))
	shower_btn.connect("pressed", Callable(self, "_on_button_pressed").bind("bathroom"))
	play_btn.connect("pressed", Callable(self, "_on_button_pressed").bind("play"))
	sleep_btn.connect("pressed", Callable(self, "_on_button_pressed").bind("sleep"))
	garage_btn.connect("pressed", Callable(self, "_on_button_pressed").bind("garage"))

func _on_button_pressed(gui_name: String):
	print("Pressed:", gui_name.capitalize(), "Button")
	for name in guis:
		guis[name].visible = (name == gui_name)
