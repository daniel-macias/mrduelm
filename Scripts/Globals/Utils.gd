extends Node

var hex_chars := "0123456789abcdef"

func generate_uuid() -> String:
	var rnd := RandomNumberGenerator.new()
	rnd.randomize()

	var part1 := _rand_hex(8, rnd)
	var part2 := _rand_hex(4, rnd)
	var part3 := "4" + _rand_hex(3, rnd)
	var part4 := hex_chars[rnd.randi_range(8, 11)] + _rand_hex(3, rnd)
	var part5 := _rand_hex(12, rnd)

	return "%s-%s-%s-%s-%s" % [part1, part2, part3, part4, part5]

func _rand_hex(length: int, rnd: RandomNumberGenerator) -> String:
	var result := ""
	for i in length:
		result += hex_chars[rnd.randi_range(0, 15)]
	return result
