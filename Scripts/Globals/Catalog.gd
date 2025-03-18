extends Node

var food_catalog = {
	"chicken": {"cost": 50, "thumbnail": "res://Sprites/Food/Chicken.png","name":"Chicken","fill":10, "health":5},
	"broccoli": {"cost": 100, "thumbnail": "res://Sprites/Food/Broccolli.png","name":"Broccoli","fill":10, "health":6},
	"pizza": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza1": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza2": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza3": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza4": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza5": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza6": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza7": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza8": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza9": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza10": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza11": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6},
	"pizza12": {"cost": 100, "thumbnail": "res://Sprites/Food/Pizza.png","name":"Pizza","fill":10, "health":6}
}

var body_parts_catalog = {
	"screen_01_green": {"cost": 50, "thumbnail": "res://Sprites/table_normal.png","name":"Early Screen", "category":"screen"},
	"body_01_eggshell": {"cost": 100, "thumbnail": "res://Sprites/shelf_normal.png","name":"Vintage 80s", "category":"body"}
}

var minigame_catalog = {
	"detector" : {"name": "Detector", "thumbnail": "res://Sprites/table_normal.png", "scene": "res://Scenes/detector.tscn"}
}

var furniture_catalog = {
	"detector" : {"name": "Detector", "thumbnail": "res://Sprites/table_normal.png", "scene": "res://Scenes/detector.tscn"}
}

func get_food_details(name):
	return food_catalog[name] if name in food_catalog else null
	
func get_body_part_details(name):
	return body_parts_catalog[name] if name in body_parts_catalog else null
