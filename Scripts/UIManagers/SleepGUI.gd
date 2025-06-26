extends Node

@onready var chargebtn : TextureButton = $HBoxContainer/ChargeBtn
@onready var cable_animator : AnimationPlayer = $"../../Camera2D/AnimationPlayerCable"

var is_on : bool = false  # Track the state of the button

const CHARGE_INTERVAL := 1.0  # Seconds between each charge tick
const CHARGE_AMOUNT := 2      # Energy points gained per tick

var charge_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button's pressed signal to the toggle function
	chargebtn.connect("pressed", Callable(self, "_on_chargebtn_pressed"))
	# Set the initial button texture based on the state
	_update_button_texture()
	
	# Setup charging timer
	charge_timer = Timer.new()
	charge_timer.wait_time = CHARGE_INTERVAL
	charge_timer.one_shot = false
	charge_timer.autostart = false
	add_child(charge_timer)
	charge_timer.connect("timeout", Callable(self, "_on_charge_tick"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_on:
		# Future logic to charge the creature every second
		print("it is on")

# Handle button press
func _on_chargebtn_pressed() -> void:
	# Toggle the state
	is_on = !is_on
	
	# Update the button texture
	_update_button_texture()
	
	# Play the appropriate animation
	if is_on:
		cable_animator.play("Conecting")
		charge_timer.start()
	else:
		cable_animator.play("Deconecting")
		charge_timer.stop()

func disconnect_cable_for_signal():
	if is_on:
		cable_animator.play("Deconecting")
		charge_timer.stop()
		is_on = false
		_update_button_texture()

# Update the button texture based on the state
func _update_button_texture() -> void:
	if is_on:
		chargebtn.texture_normal = preload("res://Sprites/UI/charging_on.png")  # Replace with your on texture path
	else:
		chargebtn.texture_normal = preload("res://Sprites/UI/charging_off.png")  # Replace with your off texture path

# Handle animation finished signal
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Conecting" or anim_name == "Deconecting":
		# Stop the animation at the last frame
		cable_animator.stop(false)
		
func _on_charge_tick() -> void:
	if is_on and GameManager.current_room == "Sleep":
		GameManager.modify_stat("energy", CHARGE_AMOUNT)
