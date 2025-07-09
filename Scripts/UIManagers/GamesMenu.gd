extends Node

@onready var back_button: TextureButton = $Back
@onready var outside_menu: Control = $"../OutsideMenu"

@export var shop_type = "minigame_catalog"
@onready var shop_template: Control = $"."
@onready var inventory_container: Control = $InventoryContainer/List
@onready var item_template: Control = $InventoryContainer/List/ItemTemplate

@onready var left_button: TextureButton = $BrowserButtons/Left
@onready var right_button: TextureButton = $BrowserButtons/Right

@onready var return_home: TextureButton = $"../OutsideMenu/HouseBtn"
@onready var xo_anim: AnimationPlayer = $XO/AnimationPlayer

var selected_item_key: String = ""  # Store the key of the selected item
var selected_item_details: Dictionary = {}  # Store the details of the selected item
var current_page: int = 0
var items_per_page: int = 6
var all_items: Array = []

func _ready() -> void:
	# Hide the template initially, this is for debugging
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	left_button.connect("pressed", Callable(self, "_on_left_button_pressed"))
	right_button.connect("pressed", Callable(self, "_on_right_button_pressed"))
	
	return_home.connect("pressed", Callable(self, "_on_return_home"))
	
	xo_anim.play("XO")
	
	xo_anim.animation_finished.connect(_on_xo_animation_finished)
	

	

func _on_shop_load(shop_type_selected: String):
	shop_type = shop_type_selected
	print("OPENED ", shop_type_selected, " SHOP")
	item_template.visible = false
	load_items()
	update_buttons()

func _on_return_home() -> void:
	outside_menu.visible = false
	GameManager.set_timers_paused(false) 

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
		
		new_item.get_node("ItemPicture").get_child(0).text = item_details["name"]
		
		# Connect the item's button signal to update the "Currently Selected" section
		var item_button = new_item  # Assuming the entire item is clickable
		item_button.get_node("ItemPicture").connect("pressed", Callable(self, "_open_game").bind(item_details["scene"]))
		
		# Add the new item to the container
		inventory_container.add_child(new_item)
	
	update_buttons()

func update_buttons() -> void:
	left_button.disabled = current_page == 0
	right_button.disabled = (current_page + 1) * items_per_page >= all_items.size()


func _on_left_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		display_page(current_page)

func _on_right_button_pressed() -> void:
	if (current_page + 1) * items_per_page < all_items.size():
		current_page += 1
		display_page(current_page)

func _on_back_button_pressed() -> void:
	self.visible = false

func _open_game(scene_path: String) -> void:
	var minigame_scene = load(scene_path).instantiate()
	get_tree().current_scene.add_child(minigame_scene) 
	self.visible = false
	GameManager.set_timers_paused(true) 
	
	if minigame_scene.has_signal("game_closed"):
		minigame_scene.game_closed.connect(_on_game_closed)

func _on_game_closed():
	self.visible = true
	

func _on_xo_animation_finished(anim_name: String) -> void:
	if anim_name == "XO":
		xo_anim.play("XO_REV")
	if anim_name == "XO_REV":
		xo_anim.play("XO")
