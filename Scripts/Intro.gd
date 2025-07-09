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

@onready var paper : TextureRect = $CanvasLayer/Control/Paper
@onready var name_lineedit : LineEdit = $CanvasLayer/Control/Paper/LineEdit
@onready var done_btn : Button = $CanvasLayer/Control/Paper/DoneBtn
@onready var paper_anim : AnimationPlayer = $CanvasLayer/Control/Paper/AnimationPlayer

@onready var loading_screen : ColorRect = $CanvasLayer/Control/LoadingBG
@onready var loading_anim : AnimationPlayer = $CanvasLayer/Control/LoadingBG/AnimationPlayer

var completed_steps := 0
var steps_done := {
	"robot": false,
	"letter": false,
	"glasses": false,
	"done": false
}

var is_paper_animating := false
var UUID = Utils.generate_uuid()

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
	paper_anim.animation_finished.connect(_on_paper_animation_finished)
	done_btn.pressed.connect(_on_done_pressed)
	anim.animation_finished.connect(_on_animation_finished)
	loading_anim.animation_finished.connect(_on_loading_animation_finished)

	paper.modulate.a = 0.0
	paper.visible = false
	

var current_step = ""

func _on_tape_input(event):
	if event is InputEventMouseButton and event.pressed and current_step == "":
		current_step = "tape"
		anim.play("tape_pull")

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
		_increment_step("robot")


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
		_increment_step("letter")
		
		# Animate paper showing up
		paper.visible = true
		
		paper_anim.play("OpeningLetter")
		
		current_step = ""
	elif anim_name == "tape_pull" and current_step == "tape":
		tape.visible = false
		current_step = ""
	elif anim_name == "glasses_pull":
		glasses.visible = false
		_increment_step("glasses")
		current_step = ""
		
func _handle_interruption(interrupted_anim: String):
	if is_paper_animating:
		return  # Prevent interruptions while the paper is appearing

	match interrupted_anim:
		"letter_pull":
			glasses.visible = true
			letter.visible = false
			print("Letter opened!")
			_increment_step("letter")

			# Trigger paper animation
			paper.visible = true
			is_paper_animating = true
			paper_anim.play("OpeningLetter")

		"tape_pull":
			tape.visible = false
		"robot_pull":
			robot.visible = false
		"glasses_pull":
			glasses.visible = false
		_:
			pass


func _on_paper_animation_finished(anim_name: String):
	if anim_name == "OpeningLetter":
		paper.modulate.a = 1.0
		is_paper_animating = false
	elif anim_name == "ClosingLetter":
		paper.modulate.a = 0.0
		paper.visible = false

func _on_done_pressed():
	print("Entered name:", name_lineedit.text)
	if name_lineedit.text != "":
		GameManager.pet_name = name_lineedit.text
	else:
		GameManager.pet_name = "X-252"
	paper_anim.play("ClosingLetter")
	_increment_step("done")
	
	GameManager.pet_uuid = UUID

func _increment_step(step: String):
	if steps_done.has(step) and not steps_done[step]:
		steps_done[step] = true
		completed_steps += 1
		if completed_steps == 4:
			print("Every step is done!")
			loading_screen.visible = true
			loading_anim.play("LoadingIn")

func _on_loading_animation_finished(anim_name: String):
	if anim_name == "LoadingIn":
		print("Done Intro")
