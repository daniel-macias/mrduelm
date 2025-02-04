extends Node

@onready var draggable_soap = $"../../Camera2D/DraggableSoap"
@onready var pet = $"../../Camera2D/Pet"
@onready var soap_selected = $HBoxContainer/Soap
@onready var camera = $"../../Camera2D"
@onready var shower_head = $ShowerHead
@onready var bubble_parent = $"../../Camera2D/Bubbles"
@onready var bubble = $"../../Camera2D/Bubbles/Bubble"
@onready var water_parent = $"../../Camera2D/Water"

var dragging = false
var drag_start_position = Vector2()
var drag_previous_position = Vector2()
var drag_threshold = 100  # Threshold for the drag to begin
var drag_step_distance = 5  # Step distance in pixels to sample along the drag path

var last_bubble_time: float = 0.0  # Track the last time a bubble was created
var bubble_cooldown: float = 0.1  # Cooldown time in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draggable_soap.visible = false
	bubble.visible = false  # Hide the original bubble initially
	
	shower_head.connect("pressed", Callable(self, "clear_bubbles"))
	
	
	for child in water_parent.get_children():
		if child is CPUParticles2D:
			child.emitting = false

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
							# Check if enough time has passed since the last bubble
							var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
							if current_time - last_bubble_time >= bubble_cooldown:
								# Display bubbles at the washed position
								display_bubble(world_sample_position)
								last_bubble_time = current_time  

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
		new_bubble.get_child(0).play("Birth")

func clear_bubbles() -> void:
	# Play "Death" animation on each bubble with a random delay
	for child in bubble_parent.get_children():
		if child != bubble:  # Skip the original bubble
			var animation_player = child.get_child(0)  # Get the AnimationPlayer
			if animation_player is AnimationPlayer:
				var random_delay = randf_range(0, 1)  # Random delay between 0 and 1 second
				get_tree().create_timer(random_delay).timeout.connect(func():
					animation_player.play("Death")
				)

	# Start all water particles immediately
	for child in water_parent.get_children():
		if child is CPUParticles2D:
			child.emitting = true  # Start particles

	# Wait for a set duration before removing the bubbles
	await get_tree().create_timer(1.5).timeout  # Adjust time as needed

	# Remove all bubbles after animations have played
	for child in bubble_parent.get_children():
		if child != bubble:
			child.queue_free()  # Remove the bubble

	# Wait for a set duration before stopping the particles
	await get_tree().create_timer(2.0).timeout  # Adjust time as needed

	# Stop all water particles
	for child in water_parent.get_children():
		if child is CPUParticles2D:
			child.emitting = false  # Stop particles
