extends Node

@onready var anim_flag = $Flag/AnimationPlayer
@onready var grass_a = [$GrassA/AnimationPlayer, $GrassA2/AnimationPlayer, $GrassA3/AnimationPlayer]
@onready var grass_b = [$GrassB/AnimationPlayer, $GrassB2/AnimationPlayer]

func _ready() -> void:
	anim_flag.play("flag")

	for anim in grass_a:
		anim.play("grassa")

	for anim in grass_b:
		anim.play("grassb")
