extends Node

@onready var draggable_soap = $"../../Camera2D/DraggableSoap"
@onready var pet = $"../../Camera2D/Pet"
@onready var soap_selected = $HBoxContainer/Soap
@onready var camera = $"../../Camera2D"
@onready var shower_head = $ShowerHead
@onready var bubble_parent = $"../../Camera2D/Bubbles"
@onready var bubble = $"../../Camera2D/Bubbles/Bubble"

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
			
			# Convert screen position to world coordinates
			var world_position = camera.get_screen_transform().affine_inverse() * event.position
			draggable_soap.position = world_position

			# Sample the drag path between the last position and the current position
			var path_vector = event.position - drag_previous_position
			var path_length = path_vector.length()
			if path_length > 0:
				var direction = path_vector.normalized()
				var steps = int(path_length / drag_step_distance)
				
				for i in range(steps):
					var sample_position = drag_previous_position + direction * drag_step_distance * i
					# Convert sample position to world coordinates
					var world_sample_position = camera.get_screen_transform().affine_inverse() * sample_position
					if pet.is_point_inside_interact_space(world_sample_position):
						var clean_amount = GameManager.clean()
						print("WASH WASH ", GameManager.cleanliness)
						if clean_amount != 1000:
							print("I am displaying bubbles") 
							display_bubble(world_sample_position)

			# Update the previous position
			drag_previous_position = event.position
			

# Function to display a bubble at the given position
func display_bubble(position: Vector2) -> void:
	if GameManager.cleanliness < 1000:
		# Duplicate the bubble
		var new_bubble = bubble.duplicate()
		new_bubble.visible = true  # Make the bubble visible
		new_bubble.position = position  # Set the bubble's position
		bubble_parent.add_child(new_bubble)  # Add the bubble to the bubble parent

# Function to clear all bubbles except the original one
func clear_bubbles() -> void:
	for child in bubble_parent.get_children():
		if child != bubble:  # Skip the original bubble
			child.queue_free()  # Remove the bubble
