extends Node

@export var shop_type = "food"  # "food", "body_parts", etc.
@onready var inventory_container: Control = $InventoryContainer/List
@onready var item_template: Control = $InventoryContainer/List/ItemTemplate
@onready var price_label: Label = $CurretlySelected/SelectedPrice
@onready var buy_button: TextureButton = $BuyBtn
@onready var left_button: TextureButton = $BrowserButtons/Left
@onready var right_button: TextureButton = $BrowserButtons/Right

var selected_item: Dictionary = {}
var current_page: int = 0
var items_per_page: int = 12
var all_items: Array = []

func _ready() -> void:
	# Hide the template initially
	item_template.visible = false
	load_items()
	update_buttons()

func load_items() -> void:
	all_items.clear()
	var items = Catalog.get(shop_type + "_catalog") if shop_type + "_catalog" in Catalog else {}
	for item_name in items.keys():
		all_items.append(item_name)
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
		var item_name = all_items[i]
		var item_details = Catalog.get(shop_type + "_catalog")[item_name]
		
		# Duplicate the template and populate it
		var new_item = item_template.duplicate()
		new_item.visible = true
		new_item.get_node("ItemPicture").texture = load(item_details["thumbnail"])
		
		new_item.get_node("ItemPicture").get_child(0).text = item_details["name"]
		new_item.get_node("ItemPicture").get_child(1).text = "$" + str(item_details["cost"])
		
		# Connect the button signal to select the item
		#new_item.get_node("BuyBtn").connect("pressed", Callable(self, "_on_item_selected").bind(item_name))
		
		# Add the new item to the container
		inventory_container.add_child(new_item)
	
	update_buttons()

func update_buttons() -> void:
	left_button.disabled = current_page == 0
	right_button.disabled = (current_page + 1) * items_per_page >= all_items.size()

func _on_item_selected(item_name: String) -> void:
	selected_item = Catalog.get(shop_type + "_catalog")[item_name]
	price_label.text = "Price: $" + str(selected_item["cost"])
	buy_button.disabled = false

func _on_buy_button_pressed() -> void:
	if selected_item:
		print("Bought:", selected_item["name"])
		selected_item = {}
		price_label.text = "Price: $0"
		buy_button.disabled = true

func _on_left_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		display_page(current_page)

func _on_right_button_pressed() -> void:
	if (current_page + 1) * items_per_page < all_items.size():
		current_page += 1
		display_page(current_page)
