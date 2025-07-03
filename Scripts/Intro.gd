extends Node

@onready var anim : AnimationPlayer = $CanvasLayer/Control/AnimationPlayer

@onready var robot : TextureRect = $CanvasLayer/Control/Robot
@onready var tape : TextureRect = $CanvasLayer/Control/Tape
@onready var glasses : TextureRect = $CanvasLayer/Control/Glasses
@onready var letter : TextureRect = $CanvasLayer/Control/Letter

@onready var closedbox : TextureRect = $CanvasLayer/Control/ClosedBox
@onready var openbox_bg : TextureRect = $CanvasLayer/Control/OpenBox
@onready var openbox_top : TextureRect = $CanvasLayer/Control/OpenBoxTop
@onready var line : TextureRect = $CanvasLayer/Control/Line

# First only show line, tape, closed box
# Play tape_pull animation after pressing on tape
# When finished tape_pull, hide tape
# Show openbox_bg, openbox_top, letter, robot after pressing closedbox or line, then hide line
# When pressing letter, play letter_pull, show glasses after animation ends and print something
# When pressing robot, play robot_pull
# When pressing glasses, play glasses_pull

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.visible = true
	tape.visible = true
	closedbox.visible = true

	openbox_bg.visible = false
	openbox_top.visible = false
	letter.visible = false
	glasses.visible = false
	robot.visible = false

	# Connect signals
	tape.gui_input.connect(_on_tape_input)
	closedbox.gui_input.connect(_on_box_input)
	line.gui_input.connect(_on_box_input)
	letter.gui_input.connect(_on_letter_input)
	robot.gui_input.connect(_on_robot_input)
	glasses.gui_input.connect(_on_glasses_input)

	# Connect animation end signal
	anim.animation_finished.connect(_on_animation_finished)

var current_step = ""

func _on_tape_input(event):
	if event is InputEventMouseButton and event.pressed and current_step == "":
		current_step = "tape"
		anim.play("tape_pull")  # Create this animation in the AnimationPlayer

func _on_box_input(event):
	if event is InputEventMouseButton and event.pressed and current_step == "":
		current_step = "box"
		line.visible = false
		closedbox.visible = false
		openbox_bg.visible = true
		openbox_top.visible = true
		letter.visible = true
		robot.visible = true

func _on_letter_input(event):
	if event is InputEventMouseButton and event.pressed:
		if anim.is_playing():
			_handle_interruption(anim.current_animation)
		current_step = "letter"
		anim.play("letter_pull") 

func _on_robot_input(event):
	if event is InputEventMouseButton and event.pressed:
		if anim.is_playing():
			_handle_interruption(anim.current_animation)
		current_step = "robot"
		anim.play("robot_pull")


func _on_glasses_input(event):
	if event is InputEventMouseButton and event.pressed:
		if anim.is_playing():
			_handle_interruption(anim.current_animation)
		current_step = "glasses"
		anim.play("glasses_pull")

func _on_animation_finished(anim_name: String):
	if anim_name == "letter_pull" and current_step == "letter":
		glasses.visible = true
		letter.visible = false
		print("Letter opened!")
		current_step = ""
	elif anim_name == "tape_pull" and current_step == "tape":
		tape.visible = false
		current_step = ""
	elif anim_name == "glasses_pull":
		glasses.visible = false
		current_step = ""
		
func _handle_interruption(interrupted_anim: String):
	match interrupted_anim:
		"letter_pull":
			glasses.visible = true
			letter.visible = false
		"tape_pull":
			tape.visible = false
		"robot_pull":
			robot.visible = false
		"glasses_pull":
			glasses.visible = false
		_:
			pass
