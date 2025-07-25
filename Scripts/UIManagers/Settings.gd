extends Node

@onready var back_button: TextureButton = $Back
@onready var xo_anim: AnimationPlayer = $XO/AnimationPlayer
@onready var settings_title: Label = $Title

@onready var eng_btn: TextureButton = $Items/EngBtn
@onready var esp_btn: TextureButton = $Items/EspBtn

@onready var selected_eng: TextureRect = $Items/EngBtn/Check
@onready var selected_esp: TextureRect = $Items/EspBtn/Check

const CONFIG_PATH := "user://language_settings.json"

func _ready() -> void:
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	xo_anim.animation_finished.connect(_on_xo_animation_finished)

	var lang := load_language()
	TranslationServer.set_locale(lang)
	_update_language_ui(lang)

	settings_title.text = tr("SETTINGS_TITLE")

	eng_btn.pressed.connect(_on_eng_selected)
	esp_btn.pressed.connect(_on_esp_selected)

	xo_anim.play("XO")


func _on_back_button_pressed() -> void:
	self.visible = false


func _on_xo_animation_finished(anim_name: String) -> void:
	if anim_name == "XO":
		xo_anim.play("XO_REV")
	elif anim_name == "XO_REV":
		xo_anim.play("XO")


func _on_eng_selected() -> void:
	TranslationServer.set_locale("en")
	save_language("en")
	_update_language_ui("en")


func _on_esp_selected() -> void:
	TranslationServer.set_locale("es")
	save_language("es")
	_update_language_ui("es")


func _update_language_ui(lang: String) -> void:
	selected_eng.visible = (lang == "en")
	selected_esp.visible = (lang == "es")
	settings_title.text = tr("SETTINGS_TITLE") 
	print(TranslationServer.get_loaded_locales())



func save_language(lang: String) -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"language": lang}))
		file.close()


func load_language() -> String:
	if FileAccess.file_exists(CONFIG_PATH):
		var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
		if file:
			var data: Dictionary = JSON.parse_string(file.get_as_text())
			return data.get("language", "en")
	return "en"  
