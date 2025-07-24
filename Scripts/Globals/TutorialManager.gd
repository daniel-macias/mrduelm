extends Node

var intro_steps = [
	"GREETING",
	"INITIAL_GAME",
	"TUTORIAL"
]

var current_step := 0
var tutorial_done := false

# Tracks which tips have been shown
var shown_tips := {}

# Called to advance to the next step
func advance_step():
	current_step += 1
	if current_step >= intro_steps.size():
		tutorial_done = true
		save_state()

func get_current_step_id() -> String:
	return intro_steps[current_step]

func skip_tutorial():
	tutorial_done = true
	save_state()

func mark_tip_as_shown(tip_id: String):
	shown_tips[tip_id] = true
	save_state()

func has_seen_tip(tip_id: String) -> bool:
	return shown_tips.get(tip_id, false)

func save_state():
	var file = FileAccess.open("user://tutorial_state.json", FileAccess.WRITE)
	if file:
		var state = {
			"tutorial_done": tutorial_done,
			"current_step": current_step,
			"shown_tips": shown_tips
		}
		file.store_string(JSON.stringify(state))
		file.close()

func load_state():
	if FileAccess.file_exists("user://tutorial_state.json"):
		var file = FileAccess.open("user://tutorial_state.json", FileAccess.READ)
		if file:
			var state = JSON.parse_string(file.get_as_text())
			tutorial_done = state.get("tutorial_done", false)
			current_step = state.get("current_step", 0)
			shown_tips = state.get("shown_tips", {})
