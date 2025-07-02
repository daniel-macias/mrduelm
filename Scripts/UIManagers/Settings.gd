extends Node

@onready var back_button: TextureButton = $Back

@onready var xo_anim: AnimationPlayer = $XO/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	xo_anim.play("XO")
	
	xo_anim.animation_finished.connect(_on_xo_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_back_button_pressed() -> void:
	self.visible = false

func _on_xo_animation_finished(anim_name: String) -> void:
	if anim_name == "XO":
		xo_anim.play("XO_REV")
	if anim_name == "XO_REV":
		xo_anim.play("XO")
