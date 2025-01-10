extends Control

@onready var food_arrow_left = $HBoxContainer/FoodArrowLeft
@onready var food_arrow_right = $HBoxContainer/FoodArrowRight
#@onready var food_selected_text = $HBoxContainer/FoodSelected
@onready var food_selected = $HBoxContainer/FoodSelected

var food_list: Array = []
var current_food_index: int = 0

func _ready() -> void:
	# Load the food inventory from the GameManager
	food_list = GameManager.inventory["food"].keys()
	
	# Set up arrow button signals
	food_arrow_left.connect("pressed", Callable(self, "_on_left_arrow_pressed"))
	food_arrow_right.connect("pressed", Callable(self, "_on_right_arrow_pressed"))
	
	# Display the initial food item
	_update_food_display()

func _on_left_arrow_pressed() -> void:
	# Move to the previous food item
	current_food_index = (current_food_index - 1 + food_list.size()) % food_list.size()
	_update_food_display()

func _on_right_arrow_pressed() -> void:
	# Move to the next food item
	current_food_index = (current_food_index + 1) % food_list.size()
	_update_food_display()

func _update_food_display():
	if food_list.size() > 0:
		var current_food = food_list[current_food_index]
		var food_details = Catalog.get_food_details(current_food) # Using the catalog to get food details

		if food_details and food_details.thumbnail:
			food_selected.texture_normal = load(food_details.thumbnail)
		else:
			print("Error: Thumbnail not found for food item:", current_food)
	else:
		print("No food items in inventory!")
		#TODO: CHANGE BACK TO ORIGINAL EMPTY INVENTORY SPRITE
