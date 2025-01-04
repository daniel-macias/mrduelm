extends Node2D

@onready var happiness_bar = $CanvasLayer/TopBar/HBoxContainer/HappyBar
@onready var hunger_bar = $CanvasLayer/TopBar/HBoxContainer/FoodBar
@onready var health_bar = $CanvasLayer/TopBar/HBoxContainer/HealthBar
@onready var energy_bar = $CanvasLayer/TopBar/HBoxContainer/EnergyBar

func update_bars():
	happiness_bar.value = GameManager.happiness
	hunger_bar.value = GameManager.hunger
	health_bar.value = GameManager.health
	energy_bar.value = GameManager.energy

func on_hunger_event():
	GameManager.modify_stat("hunger", -10)
	update_bars()
