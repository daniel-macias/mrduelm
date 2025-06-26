extends Node

# Player's starting money
var player_money: int = 500
var hunger: int = 50
var health: int = 50
var energy: int = 50
var fun: int = 50
var level: int = 0
var exp: int = 0

# Player data
var pet_name = "dwelm"
var pet_uuid = "01"

var has_played_minigame_once := false

#Hidden atributes
var cleanliness: int = 100 #out of 1000

var minigame_stats: Dictionary = {
	"detector": {
		"high_score": 0,
		"times_played": 0
	}
}


signal stat_changed(stat_name: String, new_value: int)
signal money_changed(new_amount)
signal level_changed(new_amount)


var decrease_amounts = {
	"fun": 1,
	"hunger": 2,
	"health": 1,
	"energy": 1,
}

var decrease_intervals = {
	"fun": 30.0,  # Every 30 seconds
	"hunger": 20.0,     # Every 20 seconds
	"health": 40.0,     # Every 40 seconds
	"energy": 50.0,     # Every 50 seconds
}

var timers = {}
var current_room = "Play"



# Inventory structure
var inventory: Dictionary = {
	"food": {"chicken":2, "broccoli":1},    
	"body_parts": {"plain_eggshell_body":1, "plain_eggshell_leg":1, "plain_eggshell_arm":1}, 
	"furniture":{},
	"special_items":{}
}


var equipped: Dictionary = {
	"body": "plain_eggshell_body",      
	"leg": "plain_eggshell_leg", 
	"arm": "plain_eggshell_arm",
}

func modify_stat(stat_name: String, amount: int):
	if stat_name in self:
		self[stat_name] = clamp(self[stat_name] + amount, 0, 100)
		emit_signal("stat_changed", stat_name, self[stat_name])
	else:
		print("Stat not found:", stat_name)

func _ready():
	load_game()
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
	#_decrease_stat("cleanliness")

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
	pass
	#print("Push notification:", message)

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
	
	print(inventory)

func remove_from_inventory(category: String, item_name: String, quantity: int = 1):
	if category in inventory:
		if item_name in inventory[category] and quantity > 0:
			inventory[category][item_name] -= quantity
		else:
			inventory[category][item_name] = quantity
		if inventory[category][item_name] <= 0:
			inventory[category].erase(item_name)


func clean(amount: int = 1):
	if cleanliness + amount > 1000:
		cleanliness = 1000
	else:
		cleanliness = cleanliness + amount
	
	return cleanliness

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
		emit_signal("money_changed", player_money)
		return true
	
	print("Not enough money to buy", item_details["name"])
	return false

# Pause or resume all timers
func set_timers_paused(paused: bool):
	for timer in timers.values():
		timer.set_paused(paused)

func add_money(amount):
	player_money += amount
	emit_signal("money_changed", player_money)
	
func update_high_score(minigame_name: String, score: int):
	if minigame_name in minigame_stats:
		minigame_stats[minigame_name].high_score = max(score, minigame_stats[minigame_name].high_score)
	else:
		minigame_stats[minigame_name] = { "high_score": score, "times_played": 1 }

func increment_times_played(minigame_name: String):
	if minigame_name in minigame_stats:
		minigame_stats[minigame_name].times_played += 1
	else:
		minigame_stats[minigame_name] = { "high_score": 0, "times_played": 1 }

func get_minigame_stat(minigame_name: String, stat: String) -> int:
	if minigame_name in minigame_stats and stat in minigame_stats[minigame_name]:
		return minigame_stats[minigame_name][stat]
	return 0

func add_exp(amount: int):
	exp += amount
	while exp >= get_exp_required_for_next_level():
		exp -= get_exp_required_for_next_level()
		level += 1
		print("Level Up! Now level", level)
		emit_signal("level_changed", level)

func get_exp_required_for_next_level() -> int:
	return 100 + (level * 20)  # Slightly increasing cost per level
	
func get_exp_from_score(minigame_name: String, score: int) -> int:
	match minigame_name:
		"detector":
			return score * 20  # 1 point = 20 exp
		"reaction_game":
			return score / 5  # Harder game, less exp per point
		_:
			return score  # Default


#ALL OF THIS IS RELATED TO SAVING AND LOADING:
const SAVE_PATH := "user://save_data.json"

func save_game():
	var save_data = {
		"player_money": player_money,
		"hunger": hunger,
		"health": health,
		"energy": energy,
		"fun": fun,
		"level": level,
		"exp": exp,
		"pet_name": pet_name,
		"pet_uuid": pet_uuid,
		"has_played_minigame_once": has_played_minigame_once,
		"cleanliness": cleanliness,
		"minigame_stats": minigame_stats,
		"inventory": inventory,
		"equipped": equipped
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if typeof(save_data) == TYPE_DICTIONARY:
			player_money = save_data.get("player_money", player_money)
			hunger = save_data.get("hunger", hunger)
			health = save_data.get("health", health)
			energy = save_data.get("energy", energy)
			fun = save_data.get("fun", fun)
			level = save_data.get("level", level)
			exp = save_data.get("exp", exp)
			pet_name = save_data.get("pet_name", pet_name)
			pet_uuid = save_data.get("pet_uuid", pet_uuid)
			has_played_minigame_once = save_data.get("has_played_minigame_once", has_played_minigame_once)
			cleanliness = save_data.get("cleanliness", cleanliness)
			minigame_stats = save_data.get("minigame_stats", minigame_stats)
			inventory = save_data.get("inventory", inventory)
			equipped = save_data.get("equipped", equipped)
			print("Game loaded.")
