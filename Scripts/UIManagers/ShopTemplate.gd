extends Node

@onready var back_button: TextureButton = $Back
@onready var outside_menu: Control = $"../OutsideMenu"

@export var shop_type = "food"  # "food", "body_parts", etc.
@onready var shop_template: Control = $"."
@onready var inventory_container: Control = $InventoryContainer/List
@onready var item_template: Control = $InventoryContainer/List/ItemTemplate
@onready var current_gold: Label = $CurrentGold

# Currently Selected Stuff
@onready var selected_price_label: Label = $CurretlySelected/SelectedPrice
@onready var selected_thumbnail: TextureRect = $CurretlySelected
@onready var selected_name: Label = $CurretlySelected/SelectedName

@onready var buy_button: TextureButton = $BuyBtn
@onready var left_button: TextureButton = $BrowserButtons/Left
@onready var right_button: TextureButton = $BrowserButtons/Right

# Shop types buttons
@onready var food_shop_btn: TextureButton = $"../OutsideMenu/FoodShopBtn"
@onready var furniture_shop_btn: TextureButton = $"../OutsideMenu/FurnitureShopBtn"
@onready var doctor_shop_btn: TextureButton = $"../OutsideMenu/DoctorBtn"
@onready var body_shop_btn: TextureButton = $"../OutsideMenu/BodyShopBtn"

@onready var return_home: TextureButton = $"../OutsideMenu/HouseBtn"

var selected_item_key: String = ""  # Store the key of the selected item
var selected_item_details: Dictionary = {}  # Store the details of the selected item
var current_page: int = 0
var items_per_page: int = 12
var all_items: Array = []

func _ready() -> void:
	# Hide the template initially, this is for debugging
	#_on_shop_load("food")
	
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	left_button.connect("pressed", Callable(self, "_on_left_button_pressed"))
	right_button.connect("pressed", Callable(self, "_on_right_button_pressed"))
	
	# Make the outside buttons connect to the correct shop
	food_shop_btn.connect("pressed", Callable(self, "_on_shop_load").bind("food"))
	furniture_shop_btn.connect("pressed", Callable(self, "_on_shop_load").bind("furniture"))
	doctor_shop_btn.connect("pressed", Callable(self, "_on_shop_load").bind("doctor"))
	body_shop_btn.connect("pressed", Callable(self, "_on_shop_load").bind("body_parts"))
	
	return_home.connect("pressed", Callable(self, "_on_return_home"))
	
	# Connect the BuyBtn signal
	buy_button.connect("pressed", Callable(self, "_on_buy_button_pressed"))
	buy_button.disabled = true  # Disable BuyBtn initially

func _on_shop_load(shop_type_selected: String):
	shop_type = shop_type_selected
	print("OPENED ", shop_type_selected, " SHOP")
	shop_template.visible = true
	item_template.visible = false
	load_items()
	update_buttons()

func _on_return_home() -> void:
	outside_menu.visible = false

func load_items() -> void:
	all_items.clear()
	var items = Catalog.get(shop_type + "_catalog") if shop_type + "_catalog" in Catalog else {}
	for item_key in items.keys():
		all_items.append(item_key)  # Store the keys, not the details
	display_page(current_page)

func display_page(page: int) -> void:
	# Clear existing items (except the template)
	for child in inventory_container.get_children():
		if child != item_template:
			child.queue_free()
	
	# Calculate the range of items to display
	var start_index = page * items_per_page
	var end_index = min(start_index + items_per_page, all_items.size())
	
	# Populate the page with items
	for i in range(start_index, end_index):
		var item_key = all_items[i]  # Use the key directly
		var item_details = Catalog.get(shop_type + "_catalog")[item_key]
		
		# Duplicate the template and populate it
		var new_item = item_template.duplicate()
		new_item.visible = true
		new_item.get_node("ItemPicture").texture_normal = load(item_details["thumbnail"])
		
		new_item.get_child(1).text = item_details["name"]
		new_item.get_child(2).text = "$" + str(item_details["cost"])
		
		# Connect the item's button signal to update the "Currently Selected" section
		var item_button = new_item  # Assuming the entire item is clickable
		item_button.get_node("ItemPicture").connect("pressed", Callable(self, "_on_item_selected").bind(item_key))
		
		# Add the new item to the container
		inventory_container.add_child(new_item)
	
	update_buttons()

func update_buttons() -> void:
	left_button.disabled = current_page == 0
	right_button.disabled = (current_page + 1) * items_per_page >= all_items.size()

func _on_item_selected(item_key: String) -> void:
	selected_item_key = item_key  # Store the key of the selected item
	selected_item_details = Catalog.get(shop_type + "_catalog")[item_key]  # Store the details
	
	# Update the "Currently Selected" UI
	selected_price_label.text = "Price: $" + str(selected_item_details["cost"])
	selected_thumbnail.texture = load(selected_item_details["thumbnail"])
	selected_name.text = selected_item_details["name"]
	
	# Enable BuyBtn if the player can afford the item
	buy_button.disabled = !GameManager.can_afford(selected_item_details["cost"])

func _on_buy_button_pressed() -> void:
	if selected_item_key:
		# Deduct money and add the item to the inventory
		if GameManager.buy_item(shop_type, selected_item_key):  # Use the key here
			print("Successfully bought:", selected_item_details["name"])
			# Update the UI
			current_gold.text = "Gold: $" + str(GameManager.player_money)
			selected_item_key = ""
			selected_item_details = {}
			selected_price_label.text = "Price: $0"
			selected_thumbnail.texture = null
			selected_name.text = ""
			buy_button.disabled = true
			print(GameManager.inventory)
		else:
			print("Failed to buy:", selected_item_details["name"])

func _on_left_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		display_page(current_page)

func _on_right_button_pressed() -> void:
	if (current_page + 1) * items_per_page < all_items.size():
		current_page += 1
		display_page(current_page)

func _on_back_button_pressed() -> void:
	outside_menu.visible = true
	shop_template.visible = false
