extends Node2D

@onready var animation_player_arms = $Arms/AnimationPlayerArms
@onready var animation_player_body = $AnimationPlayerBody
@onready var animation_player_eyes = $Body/AnimationPlayerEyes
@onready var interaction_space = $InteractSpace

#body parts
@onready var arms = $Arms
@onready var legs = $Legs
@onready var body = $Body/DefaultBod


func _ready():
	animation_player_arms.play("Idle")
	animation_player_body.play("Idle")
	animation_player_eyes.play("Idle")

func is_point_inside_interact_space(point: Vector2) -> bool:
	if interaction_space.polygon.size() < 3:
		return false  # Not a valid polygon
	
	var local_point = interaction_space.to_local(point)
	return Geometry2D.is_point_in_polygon(local_point, interaction_space.polygon)

func change_part_appearance(part_key: String) -> void:
	var details = Catalog.get_body_part_details(part_key)
	if details == null:
		print("Part not found:", part_key)
		return

	var texture = load(details["resource"])
	var category = details["category"]

	match category:
		"body":
			body.texture = texture

		"arm":
			for i in range(5):  # first 5 children are the sprites
				var sprite = arms.get_child(i)
				if sprite is Sprite2D:
					sprite.texture = texture

		"leg":
			var left_leg = legs.get_child(0)
			var right_leg = legs.get_child(1)
			if left_leg is Sprite2D:
				left_leg.texture = texture
			if right_leg is Sprite2D:
				right_leg.texture = texture  # already flipped in editor
