extends Node2D

@onready var animation_player_arms = $Arms/AnimationPlayerArms
@onready var animation_player_body = $AnimationPlayerBody

func _ready():
	animation_player_arms.play("Idle")
	animation_player_body.play("Idle")
