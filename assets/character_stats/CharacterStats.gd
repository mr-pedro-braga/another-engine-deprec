extends Node
class_name CharacterStats

var character_id = ""

var static_attribs = {
	"MHP": 10,
	"MPP": 10,
}

# Dynamic Attributes
var dynamic_attribs = {
	"HP": 10,
	"OF": 4,
	"DF": 4,
	"IQ": 4,
	"MP": 0,
}

func _setup(s_attribs, d_attribs, name):
	static_attribs 		= s_attribs
	dynamic_attribs 	= d_attribs
	character_id 		= name
