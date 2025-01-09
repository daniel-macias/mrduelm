extends Node

# Player's starting money
var player_money: int = 500
var hunger: int = 50
var health: int = 50
var energy: int = 50
var fun: int = 50

signal stat_changed(stat_name: String, new_value: int)

var decrease_amounts = {
	"fun": 1,
	"hunger": 2,
	"health": 1,
	"energy": 1,
}

var decrease_intervals = {
	"fun": 3.0,  # Every 3 seconds
	"hunger": 2.0,     # Every 2 seconds
	"health": 4.0,     # Every 4 seconds
	"energy": 5.0,     # Every 5 seconds
}

var timers = {}



# Inventory structure
var inventory: Dictionary = {
	"food": {},       # Stores food items and their quantities
	"body_parts": {}  # Stores body parts and their quantities
}

func modify_stat(stat_name: String, amount: int):
	if stat_name in self:
		self[stat_name] = clamp(self[stat_name] + amount, 0, 100)
		emit_signal("stat_changed", stat_name, self[stat_name])
	else:
		print("Stat not found:", stat_name)

func _ready():
	# Create and start the timer
	for stat_name in decrease_intervals.keys():
		_setup_stat_timer(stat_name)

func _setup_stat_timer(stat_name: String):
	var timer = Timer.new()
	timer.wait_time = decrease_intervals[stat_name]
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_decrease_stat").bind(stat_name))
	add_child(timer)
	timers[stat_name] = timer
	timer.start()

func _decrease_stats():
	# Decrease stats and emit signals
	_decrease_stat("hunger")
	_decrease_stat("fun")
	_decrease_stat("health")
	_decrease_stat("energy")

func _decrease_stat(stat_name: String):
	if stat_name in self:
		var decrease_amount = decrease_amounts.get(stat_name, 1)
		self[stat_name] = clamp(self[stat_name] - decrease_amount, 0, 100)
		emit_signal("stat_changed", stat_name, self[stat_name])
		
		# Example for hunger notifications
		if stat_name == "hunger" and self[stat_name] < 10:
			_send_push_notification("Your pet is hungry!")
		elif stat_name == "energy" and self[stat_name] < 10:
			_send_push_notification("Your pet is very tired!")
		elif stat_name == "health" and self[stat_name] < 10:
			_send_push_notification("Your pet's health is critical!")
		elif stat_name == "fun" and self[stat_name] < 10:
			_send_push_notification("Your pet is feeling sad!")

func _send_push_notification(message: String):
	# Simulate sending a push notification
	print("Push notification:", message)

func set_decrease_speed(stat_name: String, interval: float):
	if stat_name in timers:
		timers[stat_name].wait_time = interval
		timers[stat_name].start()
		decrease_intervals[stat_name] = interval
	else:
		print("No timer exists for stat:", stat_name)

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
