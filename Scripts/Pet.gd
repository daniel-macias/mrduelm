extends Node2D

@onready var animation_player_arms = $Arms/AnimationPlayerArms
@onready var animation_player_body = $AnimationPlayerBody
@onready var animation_player_eyes = $Body/AnimationPlayerEyes
@onready var interaction_space = $InteractSpace

func _ready():
	animation_player_arms.play("Idle")
	animation_player_body.play("Idle")
	animation_player_eyes.play("Idle")
