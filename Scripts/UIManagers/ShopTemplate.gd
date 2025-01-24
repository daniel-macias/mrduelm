extends Node

@export var shop_type = "food" # "food", "body_parts", etc.
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var price_label: Label = $Price
@onready var buy_button: TextureButton = $BuyBtn

var selected_item: Dictionary = {}

func _ready() -> void:
	# Populate the shop with items based on the shop_type
	load_items()

func load_items() -> void:
	#vbox_container.que
	var items = Catalog.get(shop_type + "_catalog") if shop_type + "_catalog" in Catalog else {}
	for item_name in items.keys():
		var item_details = items[item_name]
		# Create a button for each item
		var item_button = Button.new()
		item_button.text = item_details["name"] + " - $" + str(item_details["cost"])
		item_button.icon = load(item_details["thumbnail"])
		item_button.connect("pressed", Callable(self, "_on_item_selected").bind(item_name))
		vbox_container.add_child(item_button)
		print("ADDED: ", item_name)

func _on_item_selected(item_name: String) -> void:
	# Update selected item and UI
	selected_item = Catalog.get(shop_type + "_catalog")[item_name]
	price_label.text = "Price: $" + str(selected_item["cost"])
	buy_button.disabled = false

func _on_buy_button_pressed() -> void:
	if selected_item:
		# Logic to process the purchase
		print("Bought:", selected_item["name"])
		# Reset UI
		selected_item = {}
		price_label.text = "Price: $0"
		buy_button.disabled = true
