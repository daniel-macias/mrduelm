extends Node

@onready var workbench : TextureButton = $Workshop
@onready var instrument : TextureButton = $Instrument
@onready var workbench_menu : Control = $"../../Outside/ClothesInventory"
@onready var instrument_screen : Control = $"../../Outside/Instrument"
@onready var settings_btn : TextureButton = $HBoxContainer/SettingsBtn
@onready var settings_menu : Control = $"../../Outside/Settings"

func _ready() -> void:
	workbench.connect("pressed", Callable(self, "_on_workbench_click"))
	instrument.connect("pressed", Callable(self, "_on_instrument_click"))
	settings_btn.connect("pressed", Callable(self,"_on_settings_click"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_workbench_click() -> void:
	workbench_menu.visible = true
	workbench_menu.open_closet()
	
func _on_instrument_click() -> void:
	instrument_screen.visible = true

func _on_settings_click() -> void:
	settings_menu.visible = true
