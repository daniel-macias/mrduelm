extends Control

@onready var food_arrow_left = $HBoxContainer/FoodArrowLeft
@onready var food_arrow_right = $HBoxContainer/FoodArrowRight
@onready var food_selected_text = $HBoxContainer/FoodSelected/FoodSelectedName
@onready var food_selected = $HBoxContainer/FoodSelected
@onready var draggable_food = $"../../Camera2D/DraggableFood"
@onready var pet = $"../../Camera2D/Pet"
@onready var camera = $"../../Camera2D"

var food_list: Array = []
var current_food_index: int = 0

var current_food_dragged_key : String = ""
var dragging = false
var drag_offset = Vector2.ZERO

var drag_start_position = Vector2()
var drag_threshold = 100  # Define the threshold in pixels

func _ready() -> void:
	# Set up arrow button signals
	food_arrow_left.connect("pressed", Callable(self, "_on_left_arrow_pressed"))
	food_arrow_right.connect("pressed", Callable(self, "_on_right_arrow_pressed"))
	
	# Display the initial food item
	_update_food_display()
	
	# Hide the draggable sprite initially
	draggable_food.visible = false

func _on_left_arrow_pressed() -> void:
	# Move to the previous food item
	current_food_index = (current_food_index - 1 + food_list.size()) % food_list.size()
	_update_food_display()

func _on_right_arrow_pressed() -> void:
	# Move to the next food item
	current_food_index = (current_food_index + 1) % food_list.size()
	_update_food_display()

func _update_food_display():
	food_list = GameManager.inventory["food"].keys()
	if food_list.size() > 0:
		food_selected.disabled = false
		food_arrow_left.disabled = false
		food_arrow_right.disabled = false
		var current_food = food_list[current_food_index]
		var food_details = Catalog.get_food_details(current_food) # Using the catalog to get food details
	
		if food_details and food_details.thumbnail:
			food_selected.texture_normal = load(food_details.thumbnail)
			if current_food in GameManager.inventory["food"]:
				var text_to_display = Catalog.get_food_details(current_food)["name"] + " : " + str(GameManager.inventory['food'][current_food])
				food_selected_text.text = text_to_display
				current_food_dragged_key = current_food
			else:
				#You ran out of that food
				food_list.remove_at(current_food_index)
				print(food_list)
				current_food_index = 0
				_update_food_display()
		else:
			print("Error: Thumbnail not found for food item:", current_food)
	else:
		print("No food items in inventory!")
		food_selected_text.text = tr("EMPTY_TITLE")
		food_selected.disabled = true
		food_arrow_left.disabled = true
		food_arrow_right.disabled = true

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and GameManager.current_room == "Food":
		if event.is_pressed():
			# When touch begins
			if not food_selected.disabled and food_selected.get_global_rect().has_point(event.position):
				dragging = true
				drag_start_position = event.position
				draggable_food.visible = false  # Initially hidden until the threshold is met
				draggable_food.texture = load(Catalog.get_food_details(current_food_dragged_key).thumbnail)
				print(current_food_dragged_key)
			else:
				dragging = false

		elif event.is_released():
			# When touch ends
			dragging = false
			draggable_food.visible = false  # Hide draggable sprite when done dragging
			
			# Convert screen position to world coordinates
			var world_position = camera.get_screen_transform().affine_inverse() * event.position
			
			# Check if the food was dropped inside the InteractSpace
			if pet.is_point_inside_interact_space(world_position):
				process_food_drop()
			else:
				#print("Food dropped outside InteractSpace")
				pass
				# MAYBE LATER DO AN ANIMATION TO RETURN FOOD TO INVENTORY BUT IDK

	elif event is InputEventScreenDrag and dragging:
		var drag_distance = event.position - drag_start_position
		if drag_distance.length() > drag_threshold:
			# Make the draggable food visible and follow the finger
			draggable_food.visible = true
			
			# Convert screen position to world coordinates
			var world_position = camera.get_screen_transform().affine_inverse() * event.position
			
			# Set the position of DraggableFood in world coordinates
			draggable_food.position = world_position

func process_food_drop():
	# Deduct food from inventory, trigger animations, etc.
	if GameManager.hunger != 100:
		GameManager.remove_from_inventory("food",current_food_dragged_key)
		GameManager.modify_stat("hunger", Catalog.get_food_details(current_food_dragged_key).fill)
		_update_food_display()
