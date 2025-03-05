extends Node

@onready var back_to_game_menu_btn = $CanvasLayer/GameMenu/BackHome
@onready var start_game_btn =  $CanvasLayer/GameMenu/StartBtn
@onready var high_score_label = $CanvasLayer/GameMenu/HighScoreLabel

@onready var pause_btn = $CanvasLayer/Game/PauseGame
@onready var people_grid = $CanvasLayer/Game/GridContainer
@onready var person_template = $CanvasLayer/Game/GridContainer/Person
@onready var menu = $CanvasLayer/GameMenu
@onready var game = $CanvasLayer/Game

var mouth_textures = ["res://Sprites/Games/Detector/Mouth_0.png",
"res://Sprites/Games/Detector/Mouth_1.png",
"res://Sprites/Games/Detector/Mouth_2.png",
"res://Sprites/Games/Detector/Mouth_3.png"]

var nose_textures = ["res://Sprites/Games/Detector/Nose_0.png",
"res://Sprites/Games/Detector/Nose_1.png",
"res://Sprites/Games/Detector/Nose_2.png",
"res://Sprites/Games/Detector/Nose_3.png"]

var hair_textures = ["res://Sprites/Games/Detector/Hair_0.png",
"res://Sprites/Games/Detector/Hair_1.png",
"res://Sprites/Games/Detector/Hair_2.png",
"res://Sprites/Games/Detector/Hair_3.png",
"res://Sprites/Games/Detector/Hair_4.png",
"res://Sprites/Games/Detector/Hair_5.png"]

var eyes_textures = ["res://Sprites/Games/Detector/Eyes_0.png",
"res://Sprites/Games/Detector/Eyes_1.png",
"res://Sprites/Games/Detector/Eyes_2.png",
"res://Sprites/Games/Detector/Eyes_3.png"]

var brows_textures = ["res://Sprites/Games/Detector/Brows_0.png",
"res://Sprites/Games/Detector/Brows_1.png",
"res://Sprites/Games/Detector/Brows_2.png"]

signal game_closed  # Signal to notify when the game is closed

func _exit_game():
	game_closed.emit()  # Emit signal when exiting
	queue_free()  # Remove this minigame scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	person_template.hide()
	back_to_game_menu_btn.connect("pressed", Callable(self, "_exit_game"))
	start_game_btn.connect("pressed", Callable(self, "_start_game"))
	
func _start_game() -> void:
	menu.visible = false
	game.visible = true
	_generate_people(4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _generate_people(amount: int):
	# Clear existing people
	for child in people_grid.get_children():
		if child != person_template:
			child.queue_free()

	# Generate new people
	for i in range(amount):
		var new_person = person_template.duplicate()
		new_person.visible = true
		new_person.show()

		var children = new_person.get_children()
		children[1].texture = load(mouth_textures.pick_random()) # Mouth
		children[2].texture = load(hair_textures.pick_random())  # Hair
		children[3].texture = load(eyes_textures.pick_random())  # Eyes
		children[4].texture = load(brows_textures.pick_random()) # Brows
		children[5].texture = load(nose_textures.pick_random())  # Nose

		people_grid.add_child(new_person)
