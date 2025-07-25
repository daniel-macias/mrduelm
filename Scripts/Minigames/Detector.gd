extends Node

@onready var pause_btn = $CanvasLayer/Game/PauseGame
@onready var people_grid = $CanvasLayer/Game/GridContainer
@onready var person_template = $CanvasLayer/Game/GridContainer/Person
@onready var game = $CanvasLayer/Game
@onready var instruction = $CanvasLayer/Game/Instruction
@onready var timer_progress_bar = $CanvasLayer/Game/Machine/Clock
@onready var check_btn = $CanvasLayer/Game/CheckBtn
@onready var cat_anim = $CanvasLayer/Game/AngryCat/AnimationPlayerCat
@onready var bulbs = [$CanvasLayer/Game/Bulbs/Control/Light,$CanvasLayer/Game/Bulbs/Control2/Light,$CanvasLayer/Game/Bulbs/Control3/Light]
@onready var mistake_timer = $CanvasLayer/Game/MistakeTimer

#GAME OVER SCREEN ELEMENTS
@onready var gameover_menu = $CanvasLayer/GameOverMenu
@onready var menu_title = $CanvasLayer/GameOverMenu/Title
@onready var menu_description = $CanvasLayer/GameOverMenu/RichTextLabel
@onready var final_score_lbl = $CanvasLayer/GameOverMenu/Score
@onready var play_again_btn = $CanvasLayer/GameOverMenu/StartBtn
@onready var play_again_btn_lbl = $CanvasLayer/GameOverMenu/StartBtn/Label
@onready var price_lbl = $CanvasLayer/GameOverMenu/Price
@onready var back_btn = $CanvasLayer/GameOverMenu/BackHome

@onready var game_message_lbl = $CanvasLayer/Game/GameMessage

#PAUSE MENU ITEMS
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var resume_btn = $CanvasLayer/PauseMenu/ResumeBtn
@onready var back_to_menu_pause_btn = $CanvasLayer/PauseMenu/BackHome

var correct_amount = 0
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
	"sad": {"name": "CONDITION_SAD", "apply_condition": "_apply_sad"},
	"eyes_closed": {"name": "CONDITION_EYES_CLOSED", "apply_condition": "_apply_eyes_closed"},
	"no_mouth": {"name": "CONDITION_NO_MOUTH", "apply_condition": "_apply_no_mouth"},
	"no_nose": {"name": "CONDITION_NO_NOSE", "apply_condition": "_apply_no_nose"},
	"no_brows": {"name": "CONDITION_NO_BROWS", "apply_condition": "_apply_no_brows"},
	"no_eyes": {"name": "CONDITION_NO_EYES", "apply_condition": "_apply_no_eyes"}
}

var current_round = 0

func _exit_game():
	GameManager.has_played_minigame_once = false
	get_tree().paused = false
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
	back_btn.connect("pressed", Callable(self, "_exit_game"))
	check_btn.connect("pressed", Callable(self, "_on_check_btn_pressed"))
	cat_anim.get_parent().visible = false
	cat_anim.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	cat_anim.animation_finished.connect(_on_cat_anim_finished)
	mistake_timer.timeout.connect(_on_mistake_timer_timeout)
	play_again_btn.connect("pressed", Callable(self, "_on_play_again_pressed"))
	pause_btn.connect("pressed", Callable(self, "_on_pause_pressed"))
	resume_btn.connect("pressed", Callable(self, "_on_resume_pressed"))
	back_to_menu_pause_btn.connect("pressed", Callable(self, "_exit_game"))

	
	if !GameManager.has_played_minigame_once:
		menu_title.text = tr("DETECTOR_TITLE")
		menu_description.text = tr("DETECTOR_INSTRUCTIONS")
		play_again_btn_lbl.text = tr("START_GAME")


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
		correct_amount += 1
		start_next_round()
		mistake_timer.stop()
	else:
		register_mistake()

func generate_grid(grid_size: int, flip_amount: int, people_to_detect: int, standout_type: int, seconds_amount: float):
	# Clear previous people
	for child in people_grid.get_children():
		if child != person_template:
			child.queue_free()
	all_people.clear()
	
	var standout_keys = standout_conditions.keys()

	var key = standout_keys[standout_type]
	var condition_name = standout_conditions[key]["name"]

	instruction.bbcode_text = tr("INSTRUCTION_DETECTOR") + "[color=red]" + str(people_to_detect) + tr("PEOPLE_WITH_CONDITION_DETECTOR") + tr(condition_name)
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
	register_mistake()
	mistake_timer.start()
	

func start_next_round():
	GameManager.has_played_minigame_once = true
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
			#GAME OVER
			GameManager.save_game()
			show_game_message("Fired!", 1.0)
			await get_tree().create_timer(1.0).timeout

			print("Game Over: too many mistakes")
			mistake_timer.stop()
			timer_running = false
			game.visible = false
			gameover_menu.visible = true
			
			var money_won = correct_amount * 100

			final_score_lbl.text = str(correct_amount)
			price_lbl.text = tr("YOUR_EARNED_MINIGAME") + str(money_won)
			
			GameManager.player_money += money_won
			GameManager.emit_signal("money_changed", GameManager.player_money)
			GameManager.add_exp(GameManager.get_exp_from_score("detector", correct_amount))
			
			if GameManager.has_played_minigame_once:
				menu_title.text = tr("GAME_OVER")
				menu_description.text = tr("TRY_AGAIN_DESC")
				play_again_btn_lbl.text = tr("PLAY_AGAIN")
			
			print(GameManager.has_played_minigame_once)
			
			
			#TODO: Maybe add the ad functionality

func _on_cat_anim_finished(anim_name: String) -> void:
	if anim_name == "angry_cat":
		cat_anim.get_parent().visible = false

func _on_mistake_timer_timeout():
	register_mistake()

func _on_play_again_pressed():
	if get_tree().paused:
		get_tree().paused = false
		gameover_menu.visible = false
		return
		
	gameover_menu.visible = false
	correct_amount = 0
	current_round = 0
	mistakes = 0

	for bulb in bulbs:
		bulb.visible = true
	
	game.visible = true

	await get_tree().create_timer(0.1).timeout  # tiny delay to ensure visibility
	show_game_message("Ready?", 0.6)
	await get_tree().create_timer(0.6).timeout
	show_game_message("Go!", 0.4)
	await get_tree().create_timer(0.4).timeout
	
	start_next_round()
	

func show_game_message(text: String, duration: float = 0.5):
	game_message_lbl.text = text
	game_message_lbl.visible = true
	await get_tree().create_timer(duration).timeout
	game_message_lbl.visible = false

func _on_pause_pressed():
	pause_menu.visible = true
	game.visible = false
	get_tree().paused = true

func _on_resume_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	game.visible = true
