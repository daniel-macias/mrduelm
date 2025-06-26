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

@onready var shop_name: Label = $ShopName

@onready var xo_anim: AnimationPlayer = $XO/AnimationPlayer

@onready var pet_demo = $PetDemo

@onready var empty_cart_lbl = $EmptyCartLbl

@onready var transparent_sprite = "res://Sprites/UI/Effects/transparent.png"

var selected_item_key: String = ""  # Store the key of the selected item
var selected_item_details: Dictionary = {}  # Store the details of the selected item
var current_page: int = 0
var items_per_page: int = 12
var all_items: Array = []

func _ready() -> void:
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
	
	xo_anim.play("XO")
	
	xo_anim.animation_finished.connect(_on_xo_animation_finished)

func _on_shop_load(shop_type_selected: String):
	shop_type = shop_type_selected
	print("OPENED ", shop_type_selected, " SHOP")
	shop_template.visible = true
	item_template.visible = false
	shop_name.text = shop_type_selected
	load_items()
	update_buttons()
	
	if shop_type == "body_parts":
		pet_demo.visible = true
		center_pet_demo()
		equip_pet_demo(GameManager.equipped)
	else:
		pet_demo.visible = false
	
	reset_selection_state()

func center_pet_demo():
	var parent_size = pet_demo.get_parent().get_size()
	var center_position = parent_size / 2
	var offset = Vector2(0, 250)  # Push it downward 
	pet_demo.position = center_position + offset
	pet_demo.scale = Vector2(2, 2)  # Make it bigger

func _on_return_home() -> void:
	outside_menu.visible = false

func load_items() -> void:
	all_items.clear()
	var items = Catalog.get(shop_type + "_catalog") if shop_type + "_catalog" in Catalog else {}
	for item_key in items.keys():
		all_items.append(item_key)  # Store the keys, not the details
	display_page(current_page)
	current_gold.text = "Gold: $" + str(GameManager.player_money)

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
		
		# Check if already owned (only for body_parts)
		var owned = false
		if shop_type == "body_parts" and GameManager.inventory["body_parts"].has(item_key) and GameManager.inventory["body_parts"][item_key] == 1:
			owned = true
			# Show the checkmark (assuming it's child 4)
			new_item.get_child(4).visible = true
		else:
			new_item.get_child(4).visible = false

		# Store "owned" state in metadata for use when selected
		new_item.set_meta("owned", owned)
	
	update_buttons()

func update_buttons() -> void:
	left_button.disabled = current_page == 0
	right_button.disabled = (current_page + 1) * items_per_page >= all_items.size()

func _on_item_selected(item_key: String) -> void:
	empty_cart_lbl.visible = false
	selected_thumbnail.visible = true
	buy_button.visible = true
	
	selected_item_key = item_key
	selected_item_details = Catalog.get(shop_type + "_catalog")[item_key]
	
	# Update UI
	selected_price_label.text = "Price: $" + str(selected_item_details["cost"])
	selected_thumbnail.visible = true
	selected_name.text = selected_item_details["name"]
	
	if shop_type == "body_parts":
		selected_thumbnail.texture = load(transparent_sprite)
	else:
		selected_thumbnail.texture = load(selected_item_details["thumbnail"])
	

	# Disable Buy button if owned
	var owned = false
	if shop_type == "body_parts" and GameManager.inventory["body_parts"].has(item_key) and GameManager.inventory["body_parts"][item_key] == 1:
		owned = true

	buy_button.disabled = owned or !GameManager.can_afford(selected_item_details["cost"])
	
	if shop_type == "body_parts":
		var part_type = selected_item_details["category"]

		# Clone equipped parts to avoid modifying GameManager.equipped directly
		var preview_equipped = GameManager.equipped.duplicate()
		preview_equipped[part_type] = selected_item_key  # Replace only the part being previewed

		equip_pet_demo(preview_equipped)  # Apply preview

func _on_buy_button_pressed() -> void:
	if selected_item_key:
		# Deduct money and add the item to the inventory
		if GameManager.buy_item(shop_type, selected_item_key):  # Use the key here
			print("Successfully bought:", selected_item_details["name"])
			# Update the UI
			current_gold.text = "Gold: $" + str(GameManager.player_money)
			GameManager.save_game()

			if shop_type == "body_parts":
				reset_selection_state()
			
			print(GameManager.inventory)
			display_page(current_page)
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

func _on_xo_animation_finished(anim_name: String) -> void:
	if anim_name == "XO":
		xo_anim.play("XO_REV")
	if anim_name == "XO_REV":
		xo_anim.play("XO")

func equip_pet_demo(parts: Dictionary) -> void:
	for part_type in parts.keys():
		pet_demo.change_part_appearance(parts[part_type])

func reset_selection_state():
	selected_item_key = ""
	selected_item_details = {}
	empty_cart_lbl.visible = true
	selected_thumbnail.visible = false
	selected_name.text = ""
	selected_price_label.text = ""
	buy_button.visible = false
	buy_button.disabled = true
