extends Node

@onready var back_to_game_menu_btn = $CanvasLayer/GameMenu/BackHome
@onready var start_game_btn =  $CanvasLayer/GameMenu/StartBtn
@onready var high_score_label = $CanvasLayer/GameMenu/HighScoreLabel

@onready var pause_btn = $CanvasLayer/Game/PauseGame
@onready var people_grid = $CanvasLayer/Game/GridContainer
@onready var person_template = $CanvasLayer/Game/GridContainer/Person
@onready var menu = $CanvasLayer/GameMenu
@onready var game = $CanvasLayer/Game
@onready var instruction = $CanvasLayer/Game/Instruction
@onready var timer_progress_bar = $CanvasLayer/Game/Machine/Clock
@onready var check_btn = $CanvasLayer/Game/CheckBtn
@onready var cat_anim = $CanvasLayer/Game/AngryCat/AnimationPlayerCat
@onready var bulbs = [$CanvasLayer/Game/Bulbs/Control/Light,$CanvasLayer/Game/Bulbs/Control2/Light,$CanvasLayer/Game/Bulbs/Control3/Light]
var mistakes = 0

var mouth_textures = [
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
"res://Sprites/Games/Detector/Eyes_2.png"]

var brows_textures = ["res://Sprites/Games/Detector/Brows_0.png",
"res://Sprites/Games/Detector/Brows_1.png",
"res://Sprites/Games/Detector/Brows_2.png"]

signal game_closed  # Signal to notify when the game is closed

var round_duration = 10.0
var elapsed_time = 0.0
var timer_running = false



var standout_conditions = {
	"sad": {"name": "Sad", "apply_condition": "_apply_sad"},
	"eyes_closed": {"name": "Eyes Closed", "apply_condition": "_apply_eyes_closed"},
	"no_mouth": {"name": "No Mouth", "apply_condition": "_apply_no_mouth"},
	"no_nose": {"name": "No Nose", "apply_condition": "_apply_no_nose"},
	"no_brows": {"name": "No Brows", "apply_condition": "_apply_no_brows"},
	"no_eyes": {"name": "No Eyes", "apply_condition": "_apply_no_eyes"}
}

var current_round = 0

func _exit_game():
	game_closed.emit()  # Emit signal when exiting
	queue_free()  # Remove this minigame scene
	
func start_timer(duration: float):
	round_duration = duration
	elapsed_time = 0.0
	timer_progress_bar.value = 100
	timer_running = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	person_template.hide()
	back_to_game_menu_btn.connect("pressed", Callable(self, "_exit_game"))
	start_game_btn.connect("pressed", Callable(self, "_start_game"))
	check_btn.connect("pressed", Callable(self, "_on_check_btn_pressed"))
	cat_anim.get_parent().visible = false
	cat_anim.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	cat_anim.animation_finished.connect(_on_cat_anim_finished)
	
func _start_game() -> void:
	menu.visible = false
	game.visible = true
	
	start_next_round()
	
	for bulb in bulbs:
		bulb.visible = true
	mistakes = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		var time_left = round_duration - elapsed_time
		timer_progress_bar.value = (time_left / round_duration) * 100 

		if elapsed_time >= round_duration:
			timer_running = false
			on_time_up()

var grid_sizes = {
	2: 250,
	3: 200,
	4: 150
}

var all_people = []
var selected_people = []
var clicked_people = {}

func _on_check_btn_pressed():
	if clicked_people.keys().filter(func(i): return i in selected_people).size() == selected_people.size() \
	and clicked_people.keys().size() == selected_people.size():
		start_next_round()
	else:
		register_mistake()



func generate_grid(grid_size: int, flip_amount: int, people_to_detect: int, standout_type: int, seconds_amount: float):
	# Clear previous people
	for child in people_grid.get_children():
		if child != person_template:
			child.queue_free()
	all_people.clear()
	
	instruction.bbcode_text = "Detect [color=red]" + str(people_to_detect) + "[/color] people with the feature: " + standout_conditions.keys()[standout_type]
	start_timer(seconds_amount)
	
	round_duration = round_duration

	#Restart select tracker
	selected_people.clear()
	clicked_people.clear()
	
	# Set the correct grid columns
	people_grid.columns = grid_size

	# Get the correct character size
	var character_size = grid_sizes.get(grid_size, 200) # Default to 3x3 size

	# Hide template
	person_template.hide()

	# Create people for the grid
	var total_people = grid_size * grid_size
	

	# Randomly select unique people to be affected
	while selected_people.size() < people_to_detect:
		var random_index = randi() % total_people
		if random_index not in selected_people:
			selected_people.append(random_index)
	
	for i in range(total_people):
		var new_person = person_template.duplicate()
		new_person.show()
		people_grid.add_child(new_person)
		all_people.append(new_person)

		# Resize person
		new_person.set_custom_minimum_size(Vector2(character_size, character_size))

		# Get children
		var parts = new_person.get_children()
		if parts.size() >= 7:  # Ensure correct structure
			parts[2].texture = load(mouth_textures.pick_random()) 
			parts[3].texture = load(hair_textures.pick_random())  
			parts[4].texture = load(eyes_textures.pick_random())  
			parts[5].texture = load(brows_textures.pick_random())  
			parts[6].texture = load(nose_textures.pick_random()) 

			# Resize each part
			for part in parts:
				part.set_size(Vector2(character_size, character_size))
				
		if i in selected_people:
			apply_standout_feature(new_person, standout_type)
		new_person.connect("gui_input", Callable(self, "_on_person_clicked").bind(i))
		
	flip_random_people(flip_amount)


func flip_random_people(flip_amount: int):
	if flip_amount <= 0 or all_people.size() == 0:
		return
	
	var flipped_indices = []
	while flipped_indices.size() < flip_amount:
		var random_index = randi() % all_people.size()
		if random_index not in flipped_indices:
			flipped_indices.append(random_index)
	
	for index in flipped_indices:
		var person = all_people[index]
		var flip_h = randi() % 2 == 0  # Randomly decide if horizontal flip
		var flip_v = randi() % 2 == 0  # Randomly decide if vertical flip

		# Apply flipping to all parts
		for part in person.get_children():
			part.flip_h = flip_h
			part.flip_v = flip_v

# Function to apply standout feature (e.g., sad, eyes closed, etc.)
func apply_standout_feature(person, standout_type):
	var condition_name = standout_conditions.keys()[standout_type]  # Get the condition from the type
	var condition = standout_conditions[condition_name]
	var apply_method = condition["apply_condition"]
	call_deferred(apply_method, person)  # Apply the standout condition method

# Example condition function: apply sad face
func _apply_sad(person):
	var parts = person.get_children()
	parts[2].texture = load("res://Sprites/Games/Detector/Mouth_0.png")  # Set a sad mouth

# Example condition function: apply eyes closed
func _apply_eyes_closed(person):
	var parts = person.get_children()
	parts[4].texture = load("res://Sprites/Games/Detector/Eyes_3.png")  # Set eyes closed texture
	
func _apply_no_mouth(person):
	var parts = person.get_children()
	parts[2].texture = null 

func _apply_no_nose(person):
	var parts = person.get_children()
	parts[5].texture = null 

func _apply_no_brows(person):
	var parts = person.get_children()
	parts[6].texture = null 

func _apply_no_eyes(person):
	var parts = person.get_children()
	parts[4].texture = null

func on_time_up():
	print("Time's up!")
	

func start_next_round():
	if current_round < DetectorRounds.get_rounds().size():
		var round_data = DetectorRounds.get_rounds()[current_round]
		generate_grid(
			round_data["grid_size"],
			round_data["flip_amount"],
			round_data["people_to_detect"],
			round_data["standout_type"],
			round_data["duration"]
		)
		start_timer(round_data["duration"]) 
		current_round += 1
	else:
		print("Game Over! No more rounds.")

func _on_person_clicked(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		var person = all_people[index]
		var circle = person.get_child(7)  # Circle is the 8th child (index 7)

		# If already selected, deselect
		if index in clicked_people:
			clicked_people.erase(index)
			circle.visible = false  # Hide the circle
		else:
			clicked_people[index] = true
			circle.visible = true  # Show the circle

func register_mistake():
	if mistakes < bulbs.size():
		bulbs[mistakes].visible = false
		mistakes += 1
		var cat_node = cat_anim.get_parent()
		cat_node.visible = true
		cat_anim.play("angry_cat")
		
		if mistakes >= bulbs.size():
			print("Game Over: too many mistakes")
			_exit_game()

func _on_cat_anim_finished(anim_name: String) -> void:
	if anim_name == "angry_cat":
		cat_anim.get_parent().visible = false
