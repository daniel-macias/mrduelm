extends Node2D

@onready var animation_player_arms = $Arms/AnimationPlayerArms
@onready var animation_player_body = $AnimationPlayerBody
@onready var animation_player_eyes = $Body/AnimationPlayerEyes
@onready var interaction_space = $InteractSpace

func _ready():
	animation_player_arms.play("Idle")
	animation_player_body.play("Idle")
	animation_player_eyes.play("Idle")

func is_point_inside_interact_space(point: Vector2) -> bool:
	if interaction_space.polygon.size() < 3:
		return false  # Not a valid polygon
	
	var local_point = interaction_space.to_local(point)
	return Geometry2D.is_point_in_polygon(local_point, interaction_space.polygon)
