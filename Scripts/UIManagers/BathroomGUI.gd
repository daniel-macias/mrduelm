extends Node

@onready var draggable_soap = $"../../DraggableSoap"
@onready var pet = $"../../Pet"
@onready var soap_selected = $HBoxContainer/Soap

var dragging = false
var drag_offset = Vector2.ZERO

var drag_start_position = Vector2()
var drag_threshold = 100  # Define the threshold in pixels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draggable_soap.visible = false

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and GameManager.current_room == "Bathroom":
		if event.is_pressed():
			# When touch begins
			if not soap_selected.disabled and soap_selected.get_global_rect().has_point(event.position):
				dragging = true
				drag_start_position = event.position
				draggable_soap.visible = false  # Initially hidden until the threshold is met
			else:
				dragging = false

		elif event.is_released():
			# When touch ends
			dragging = false
			draggable_soap.visible = false  # Hide draggable sprite when done dragging
			# Check if the food was dropped inside the InteractSpace
			if pet.is_point_inside_interact_space(event.position):
				#process_food_drop()
				pass
			else:
				#print("Food dropped outside InteractSpace")
				pass
				#MAYBE LATER DO AN ANIMATION TO RETURN FOOD TO INVENTORY BUT IDK

	elif event is InputEventScreenDrag and dragging:
		var drag_distance = event.position - drag_start_position
		if drag_distance.length() > drag_threshold:
			# Make the draggable food visible and follow the finger
			draggable_soap.visible = true
			draggable_soap.position = event.position
			if pet.is_point_inside_interact_space(event.position):
				print("WASH WASH")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
