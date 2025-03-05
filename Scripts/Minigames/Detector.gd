extends Node

@onready var back_to_game_menu_btn = $CanvasLayer/GameMenu/BackHome
@onready var start_game_btn =  $CanvasLayer/GameMenu/StartBtn
@onready var high_score_label = $CanvasLayer/GameMenu/HighScoreLabel

signal game_closed  # Signal to notify when the game is closed

func _exit_game():
	game_closed.emit()  # Emit signal when exiting
	queue_free()  # Remove this minigame scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_to_game_menu_btn.connect("pressed", Callable(self, "_exit_game"))
	start_game_btn.connect("pressed", Callable(self, "_start_game"))
	
func _start_game() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
