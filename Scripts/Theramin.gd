extends Control

@onready var player: AudioStreamPlayer = $SoundPlayer
@onready var back_btn: TextureButton = $Back
@onready var sound_space: ColorRect = $SoundSpace
@onready var crosshair: TextureRect = $Crosshair

var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

var is_touching := false
var current_touch_pos := Vector2.ZERO
var tone_time := 0.0

func _ready():
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.5
	player.stream = generator
	player.play()
	playback = player.get_stream_playback()

	back_btn.pressed.connect(_on_back_pressed)
	crosshair.visible = false

func _input(event):
	if not visible:
		return

	if event is InputEventScreenTouch or event is InputEventMouseButton:
		is_touching = event.pressed
		if is_touching:
			current_touch_pos = event.position
			crosshair.visible = true
		else:
			crosshair.visible = false

	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_touching:
		current_touch_pos = event.position

func _process(delta):
	if not visible or not is_touching:
		return

	var rect_pos = sound_space.get_global_position()
	var rect_size = sound_space.size
	var rect = Rect2(rect_pos, rect_size)

	if not rect.has_point(current_touch_pos):
		crosshair.visible = false
		return

	var local_pos = current_touch_pos - rect_pos
	var normalized_x = clamp(local_pos.x / rect_size.x, 0.0, 1.0)
	var normalized_y = clamp(local_pos.y / rect_size.y, 0.0, 1.0)

	var pitch = lerp(200.0, 1000.0, normalized_y)

	var vol = lerp(0.1, 1.0, normalized_x)

	# Move crosshair to match input
	crosshair.position = rect_pos + local_pos - crosshair.size * 0.5

	var available = playback.get_frames_available()
	var samples_to_generate = min(available, int(generator.mix_rate * delta))

	for i in range(samples_to_generate):
		var sample = sin(2.0 * PI * pitch * tone_time) * vol
		playback.push_frame(Vector2(sample, sample))
		tone_time += 1.0 / generator.mix_rate

func _on_back_pressed():
	visible = false
	is_touching = false
	tone_time = 0.0
	crosshair.visible = false
