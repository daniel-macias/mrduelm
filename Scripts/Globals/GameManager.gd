extends Node

# Player's starting money
var player_money: int = 500

# Inventory structure
var inventory: Dictionary = {
	"food": {},       # Stores food items and their quantities
	"body_parts": {}  # Stores body parts and their quantities
}

# Check if the player can afford an item
func can_afford(cost: int) -> bool:
	return player_money >= cost

# Deduct money if affordable
func spend_money(cost: int) -> bool:
	if can_afford(cost):
		player_money -= cost
		return true
	return false

# Add item to inventory
func add_to_inventory(category: String, item_name: String, quantity: int = 1):
	if category in inventory:
		if item_name in inventory[category]:
			inventory[category][item_name] += quantity
		else:
			inventory[category][item_name] = quantity

# Handle purchasing an item
func buy_item(category: String, item_name: String, quantity: int = 1) -> bool:
	# Get item details from Catalog
	var item_details = null
	if category == "food":
		item_details = Catalog.get_food_details(item_name)
	elif category == "body_parts":
		item_details = Catalog.get_body_part_details(item_name)
	
	# Check if item exists
	if item_details == null:
		print("Item not found in catalog:", item_name)
		return false
	
	# Calculate the total cost
	var total_cost = item_details["cost"] * quantity
	
	# Check if the player can afford the item
	if spend_money(total_cost):
		add_to_inventory(category, item_name, quantity)
		print("Successfully bought", quantity, "of", item_details["name"])
		return true
	
	print("Not enough money to buy", item_details["name"])
	return false
