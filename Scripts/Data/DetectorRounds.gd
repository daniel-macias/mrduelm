extends Node

var rounds = [
	{ "grid_size": 2, "flip_amount": 1, "people_to_detect": 2, "standout_type": 2, "duration": 20 },
	{ "grid_size": 2, "flip_amount": 1, "people_to_detect": 2, "standout_type": 2, "duration": 15 },
	{ "grid_size": 2, "flip_amount": 1, "people_to_detect": 2, "standout_type": 2, "duration": 10 },
	{ "grid_size": 3, "flip_amount": randi_range(2, 3), "people_to_detect": 2, "standout_type": 2, "duration": 25 },
	{ "grid_size": 4, "flip_amount": randi_range(2, 3), "people_to_detect": 2, "standout_type": 2, "duration": 25 }
]

func get_rounds():
	return rounds
