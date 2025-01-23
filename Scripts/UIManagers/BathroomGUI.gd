extends Node

@onready var draggable_soap = $"../../DraggableSoap"
@onready var pet = $"../../Pet"
@onready var soap_selected = $HBoxContainer/Soap

var dragging = false
var drag_start_position = Vector2()
var drag_previous_position = Vector2()
var drag_threshold = 100  # Threshold for the drag to begin
var drag_step_distance = 5  # Step distance in pixels to sample along the drag path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draggable_soap.visible = false

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and GameManager.current_room == "Bathroom":
		if event.is_pressed():
			# Start dragging if the touch begins on the soap
			if not soap_selected.disabled and soap_selected.get_global_rect().has_point(event.position):
				dragging = true
				drag_start_position = event.position
				drag_previous_position = event.position  # Initialize the previous position
				draggable_soap.visible = false  # Initially hidden
			else:
				dragging = false

		elif event.is_released():
			# End dragging
			dragging = false
			draggable_soap.visible = false  # Hide the draggable soap
			# Additional logic for dropping the soap if needed

	elif event is InputEventScreenDrag and dragging:
		var drag_distance = event.position - drag_start_position
		if drag_distance.length() > drag_threshold:
			# Make the draggable soap visible and follow the drag position
			draggable_soap.visible = true
			draggable_soap.position = event.position

			# Sample the drag path between the last position and the current position
			var path_vector = event.position - drag_previous_position
			var path_length = path_vector.length()
			if path_length > 0:
				var direction = path_vector.normalized()
				var steps = int(path_length / drag_step_distance)
				
				for i in range(steps):
					var sample_position = drag_previous_position + direction * drag_step_distance * i
					if pet.is_point_inside_interact_space(sample_position):
						GameManager.clean()
						print("WASH WASH ", GameManager.cleanliness)
						#TODO: UI feedback to 100% clean

			# Update the previous position
			drag_previous_position = event.position
