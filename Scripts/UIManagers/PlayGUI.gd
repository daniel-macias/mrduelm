extends Node

@onready var door : TextureButton = $Door
@onready var outside_menu : Control = $"../../Outside/OutsideMenu"
@onready var toybox : TextureButton = $ToyBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door.connect("pressed", Callable(self, "_on_door_click"))
	toybox.connect("pressed", Callable(self, "_on_toybox_click"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_door_click() -> void:
	outside_menu.visible = true
	
func _on_toybox_click() -> void:
	GameManager.modify_stat("fun", 10)
