extends Node

var food_catalog = {
	"pizza_veggie": {"cost": 50, "thumbnail": "res://Sprites/Food/pizza_veggie.png","name":"Veggie Pizza","fill":10, "health":5},
	"broccoli": {"cost": 100, "thumbnail": "res://Sprites/Food/broccolli.png","name":"Broccoli","fill":10, "health":6},
	"rice": {"cost": 100, "thumbnail": "res://Sprites/Food/rice.png","name":"Rice","fill":10, "health":6},
	"khachapuri": {"cost": 100, "thumbnail": "res://Sprites/Food/khachapuri.png","name":"Khachapuri","fill":10, "health":6},
	"pizza_metal": {"cost": 100, "thumbnail": "res://Sprites/Food/pizza_metal.png","name":"Metal Pizza","fill":10, "health":6},
	"petroleum_jelly": {"cost": 100, "thumbnail": "res://Sprites/Food/petroleum_jelly.png","name":"Petroleum Jelly","fill":10, "health":6},
	"oil_protein": {"cost": 100, "thumbnail": "res://Sprites/Food/oil_protein.png","name":"Oil Protein Shake","fill":10, "health":6},
	"metal_pop": {"cost": 100, "thumbnail": "res://Sprites/Food/metal_pop.png","name":"Screwdriver Pop","fill":10, "health":6},
	"pizza_pepperoni": {"cost": 100, "thumbnail": "res://Sprites/Food/pizza_pepperoni.png","name":"Pepperoni Pizza","fill":10, "health":6},
	"chicken": {"cost": 100, "thumbnail": "res://Sprites/Food/chicken.png","name":"Chicken","fill":10, "health":6},
	"steak": {"cost": 100, "thumbnail": "res://Sprites/Food/steak.png","name":"Steak","fill":10, "health":6},
	"beef_wellington": {"cost": 100, "thumbnail": "res://Sprites/Food/beef_wellington.png","name":"Beef Wellington","fill":10, "health":6}
}

var body_parts_catalog = {
	"screen_01_green": {"cost": 50, "thumbnail": "res://Sprites/table_normal.png","name":"Early Screen", "category":"screen"},
	"body_01_eggshell": {"cost": 100, "thumbnail": "res://Sprites/shelf_normal.png","name":"Vintage 80s", "category":"body"}
}

var minigame_catalog = {
	"detector" : {"name": "Detector", "thumbnail": "res://Sprites/table_normal.png", "scene": "res://Scenes/detector.tscn"}
}

var furniture_catalog = {
	"test_furniture" : {"name": "Test Furniture", "thumbnail": "res://Sprites/table_normal.png", "cost": 100}
}

func get_food_details(name):
	return food_catalog[name] if name in food_catalog else null
	
func get_body_part_details(name):
	return body_parts_catalog[name] if name in body_parts_catalog else null
