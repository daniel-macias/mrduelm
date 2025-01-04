extends Node

var food_catalog = {
	"carrot": {"cost": 50, "thumbnail": "res://Sprites/table_normal.png","name":"Carrot","fill":10, "health":5},
	"apple": {"cost": 100, "thumbnail": "res://Sprites/shelf_normal.png","name":"Apple","fill":10, "health":6}
}

var body_parts_catalog = {
	"screen_01_green": {"cost": 50, "thumbnail": "res://Sprites/table_normal.png","name":"Early Screen", "category":"screen"},
	"body_01_eggshell": {"cost": 100, "thumbnail": "res://Sprites/shelf_normal.png","name":"Vintage 80s", "category":"body"}
}

func get_food_details(name):
	return food_catalog[name] if name in food_catalog else null
	
func get_body_part_details(name):
	return body_parts_catalog[name] if name in body_parts_catalog else null