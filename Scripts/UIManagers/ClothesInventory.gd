extends Node

@onready var back_button: TextureButton = $Back
@onready var outside_menu: Control = $"../OutsideMenu"

@export var shop_type = "clothes_inventory"
@onready var shop_template: Control = $"."
@onready var inventory_container: Control = $InventoryContainer/List
@onready var item_template: Control = $InventoryContainer/List/ItemTemplate

@onready var left_button: TextureButton = $BrowserButtons/Left
@onready var right_button: TextureButton = $BrowserButtons/Right

@onready var return_home: TextureButton = $"../OutsideMenu/HouseBtn"
@onready var xo_anim: AnimationPlayer = $XO/AnimationPlayer

@onready var pet_demo = $PetDemo

@onready var selected_name: Label = $SelectedName
@onready var buy_button: TextureButton = $BuyBtn

signal pet_needs_update

var selected_item_key: String = ""  # Store the key of the selected item
var selected_item_details: Dictionary = {}  # Store the details of the selected item
var current_page: int = 0
var items_per_page: int = 8
var all_items: Array = []

func _ready() -> void:
	# Hide the template initially, this is for debugging
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	left_button.connect("pressed", Callable(self, "_on_left_button_pressed"))
	right_button.connect("pressed", Callable(self, "_on_right_button_pressed"))
	
	return_home.connect("pressed", Callable(self, "_on_return_home"))
	
	buy_button.connect("pressed", Callable(self,"_on_equip_button_pressed"))
	
	xo_anim.play("XO")
	
	xo_anim.animation_finished.connect(_on_xo_animation_finished)


func open_closet() -> void:
	print("OPENED CLOSET")
	item_template.visible = false
	load_items()
	update_buttons()
	reset_selection_state()
	pet_demo.visible = true
	center_pet_demo()
	equip_pet_demo(GameManager.equipped)


func _on_return_home() -> void:
	outside_menu.visible = false
	GameManager.set_timers_paused(false) 

func load_items() -> void:
	all_items.clear()
	var catalog = Catalog.get("body_parts_catalog") if "body_parts_catalog" in Catalog else {}

	for item_key in catalog.keys():
		if GameManager.inventory["body_parts"].has(item_key):
			all_items.append(item_key)

	display_page(current_page)


func display_page(page: int) -> void:
	# Clear existing items (except the template)
	for child in inventory_container.get_children():
		if child != item_template:
			child.queue_free()
	
	var start_index = page * items_per_page
	var end_index = min(start_index + items_per_page, all_items.size())

	for i in range(start_index, end_index):
		var item_key = all_items[i]
		var item_details = Catalog.get("body_parts_catalog")[item_key]
		var category = item_details["category"]

		# Duplicate the template and populate it
		var new_item = item_template.duplicate()
		new_item.visible = true
		new_item.get_node("ItemPicture").texture_normal = load(item_details["thumbnail"])

		# Append [equipped] if the item is currently equipped
		var item_name = item_details["name"]
		if GameManager.equipped.has(category) and GameManager.equipped[category] == item_key:
			item_name += " [equipped]"

		new_item.get_node("ItemPicture").get_child(0).text = item_name

		# Connect selection logic
		var item_button = new_item
		item_button.get_node("ItemPicture").connect("pressed", Callable(self, "_on_item_selected").bind(item_key))

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

func equip_pet_demo(parts: Dictionary) -> void:
	for part_type in parts.keys():
		pet_demo.change_part_appearance(parts[part_type])
		

func _on_item_selected(item_key: String) -> void:
	selected_item_key = item_key
	selected_item_details = Catalog.get("body_parts_catalog")[item_key]

	selected_name.text = selected_item_details["name"]
	buy_button.visible = true
	buy_button.disabled = false

	# Preview equip
	var preview = GameManager.equipped.duplicate()
	preview[selected_item_details["category"]] = item_key
	equip_pet_demo(preview)

func _on_equip_button_pressed() -> void:
	if selected_item_key != "":
		var category = selected_item_details["category"]
		GameManager.equipped[category] = selected_item_key
		print("Equipped", category, "with:", selected_item_key)
		print("hola ", GameManager.equipped)
		equip_pet_demo(GameManager.equipped)
		reset_selection_state()
		emit_signal("pet_needs_update")

func center_pet_demo():
	var parent_size = pet_demo.get_parent().get_size()
	pet_demo.position = parent_size / 2 + Vector2(0, 250)
	pet_demo.scale = Vector2(2, 2)


func reset_selection_state():
	selected_item_key = ""
	selected_item_details = {}
	selected_name.text = ""
	buy_button.visible = false
	buy_button.disabled = true
