extends Node

@onready var workbench : TextureButton = $Workshop
@onready var instrument : TextureButton = $Instrument
@onready var workbench_menu : Control = $"../../Outside/ClothesInventory"

func _ready() -> void:
	workbench.connect("pressed", Callable(self, "_on_workbench_click"))
	instrument.connect("pressed", Callable(self, "_on_instrument_click"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_workbench_click() -> void:
	workbench_menu.visible = true
	workbench_menu.open_closet()
	
func _on_instrument_click() -> void:
	print("Instrument Clicked")
