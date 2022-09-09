#
#
#			Scene Script Extension (Attack) 1.0.0
#				by Pedro Braga
#
#
# An utility class made to parse SceneScript Attacks
#  from Scene Script Object Notation.

class_name SSEX_Attack

#@ Parses a *.sson file into a list of attack objects.
static func parse_sson_atk(raw):
	var regex = RegEx.new()
	var _error = regex.compile("(?m)^ *--(?<key>[\\w|\\*]+) *((?<value>.*)(?<block>(?:\\n\\t.*)*)?)?")
	if _error != OK:
		print_debug(_error, raw)
	
	var results := {}
	
	for m in regex.search_all(raw):
		var names = m.get_names()
		
		var attack = parse_atk(SceneScript.unindent(
			m.get_string(names["block"])
		))
		
		if not attack == []:
			results[m.get_string(names["key"])] = attack
	
	return results

#@ Parses an attack from scene script into JSON
static func parse_atk(raw):
	var regex = RegEx.new()
	regex.compile("(?m)^ *(?<command>[\\w|\\*]+) *((?<params>.*)(?<block>(?:\\n\\t.*)*)?)?")
	var results := []
	
	for m in regex.search_all(raw):
		var line = parse_atk_entry(m)
		if not line == {}:
			results.push_back(
				line
			)
	
	return results

#@ Reads an attack from the parset JSON into another fucking dictionary
static func read_atk(par_array):
	var result := {}
	for i in par_array:
		match i.type:
			"type":
				result.type = i.value
			"battle_box":
				Utils.battle_box_size = i.value
				BattleCore.battle.update_size(i.value)
				result.anim_in = i.anim_in
				result.anim_out = i.anim_out
			"source":
				result.minigame_source = i.value
	result.content = par_array
	return result

#@ Parses a single entry of ATK
static func parse_atk_entry(raw_match):
	var names = raw_match.get_names()
	
	var r = {}
	
	var command:String = raw_match.get_string(names["command"])
	var params = raw_match.get_string(names["params"])
	var block = raw_match.get_string(names["block"])
	
	# Match Normal Commands
	match command:
		"base_damage":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "damage",
				"damage": {
					"amount": float(terms[0]),
					"damage_type": terms[1]
				}
			}
		"scene":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "setting",
				"setting": "scene",
				"scene": params.strip_edge().to_lower()
			}
		"type":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "type",
				"value": {"wait":-1, "minigame":0, "bullets":1, "animation":2}[params.strip_edges()]
			}
		"battle_box":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "battle_box",
				"value": Vector2(int(terms[0]), int(terms[1])),
				"anim_in": terms[2],
				"anim_out": terms[3]
			}
		"bullet_count":
			r = {
				"type": "bullet_count",
				"value": (params)
			}
		"source":
			r = {
				"type": "source",
				"value": (params)
			}
		"script":
			r = {
				"type": "script",
				"content": parse_script(SceneScript.unindent(block))
			}
		"clock_interval":
			r = {
				"type": "param",
				"param": "clock_interval",
				"value": float(params)
			}
		"spawn_count":
			r = {
				"type": "param",
				"param": "spawn_count",
				"value": float(params)
			}
		"rate":
			r = {
				"type": "param",
				"param": "rate",
				"value": float(params)
			}
		"beatcode_script":
			r = {
				"type": "param",
				"param": "beatcode_script",
				"value": params
			}
		"beatcode_tempo":
			r = {
				"type": "param",
				"param": "beatcode_tempo",
				"value": float(params)
			}
		_:
			pass
	return r

#@ Parses a bullet script section from SC into json
static func parse_script(raw):
	var regex = RegEx.new()
	regex.compile("(?m)^ *(?<command>[\\w|\\*]+) *((?<params>.*)(?<block>(?:\\n\\t.*)*)?)?")
	var results := []
	
	for m in regex.search_all(raw):
		var line = parse_script_entry(m)
		if not line == {}:
			results.push_back(
				line
			)
	
	return results

#@ Parses a single entry of bullet script
static func parse_script_entry(raw_match):
	var names = raw_match.get_names()
	var r = {}
	
	var command:String = raw_match.get_string(names["command"])
	var params = raw_match.get_string(names["params"])
	var block = raw_match.get_string(names["block"])
	
	# Match Normal Commands
	match command:
		"process":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "process",
				"value": {"static":0, "projectile":1}[params.strip_edges()]
			}
		"delete":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "delete"
			}
		"sprite":
			r = {
				"type": "sprite",
				"value": (params)
			}
		"once":
			r = {
				"type": "condition",
				"condition": "%%FIRST_TURN",
				"content": parse_script(SceneScript.unindent(block))
			}
		"if":
			r = {
				"type": "condition",
				"condition": params,
				"content": parse_script(SceneScript.unindent(block))
			}
		"offset":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "function",
				"function": "offset_at_angle",
				"param": Vector2(float(terms[0]), float(terms[1]))
			}
		"speed":
			r = {
				"type": "param",
				"param": "speed",
				"value": (params)
			}
		"battle_box_position":
			r = {
				"type": "param",
				"param": "battle_box_position",
				"value": (params)
			}
		"gravity_angle":
			r = {
				"type": "param",
				"param": "gravity_angle",
				"value": (params)
			}
		"soul_gravity_angle":
			r = {
				"type": "param",
				"param": "soul_gravity_angle",
				"value": (params)
			}
		"gravity":
			r = {
				"type": "param",
				"param": "gravity",
				"value": (params)
			}
		"life_time":
			r = {
				"type": "param",
				"param": "life_time",
				"value": (params)
			}
		"angle":
			r = {
				"type": "param",
				"param": "angle",
				"value": (params)
			}
		"sprite_angle":
			r = {
				"type": "param",
				"param": "sprite_angle",
				"value": (params)
			}
		"accel_angle":
			r = {
				"type": "param",
				"param": "acceleration_angle",
				"value": (params)
			}
		"accel":
			r = {
				"type": "param",
				"param": "accel",
				"value": params
			}
		"lookat":
			var terms = SceneScript.get_terms(params)
			r = {
				"type": "function",
				"function": "look_at",
				"param": Vector2(float(terms[0]), float(terms[1]))
			}
		"position":
			r = {
				"type": "param",
				"param": "position",
				"value": params
			}
		"face_movement":
			r = {
				"type": "param",
				"param": "face_movement",
				"value": true
			}
		"torus_border":
			r = {
				"type": "torus_border"
			}
		"damage_scale":
			r = {
				"type": "param",
				"param": "damage_scale",
				"value": (params.strip_edges())
			}
		"damage_mode":
			r = {
				"type": "param",
				"param": "damage_mode",
				"value": {"normal":"0", "when_moving":"1", "idle":"2"}[params.strip_edges()]
			}
		_:
			r = {}
	if r == {}:
		return
	return r


















