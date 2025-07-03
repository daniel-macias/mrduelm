extends Control

@onready var title = $PanelContainer/VBoxContainer/Panel/TopBar/Title
@onready var desc = $PanelContainer/VBoxContainer/InfoText
@onready var close_btn = $PanelContainer/VBoxContainer/Panel/TopBar/Exit
@onready var bg_panel = $BGPanel
@onready var skip_btn = $PanelContainer/VBoxContainer/SkipBtn

signal skipped

func _ready():
	close_btn.pressed.connect(_on_close)
	bg_panel.gui_input.connect(_on_bg_panel_input)
	skip_btn.pressed.connect(_on_skip)
	visible = false

func _on_close():
	hide()

func _on_skip():
	emit_signal("skipped")
	hide()

#show_dialog("Welcome", "Tap your pet", true)
func show_dialog(dialog_title: String, dialog_desc: String, show_skip: bool = false):
	title.text = dialog_title
	desc.text = dialog_desc
	skip_btn.visible = show_skip
	show()

func _on_bg_panel_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		_on_close()
