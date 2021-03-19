extends ColorRect

onready var spectrum = AudioServer.get_bus_effect_instance(3, 0)

export var min_freq = 20
export var max_freq = 5000
var maxdb = -16
var mindb = -55

func _process(delta):
	var freq = min_freq
	var interval = (max_freq - min_freq)
	var mag = spectrum.get_magnitude_for_frequency_range(freq, freq + interval)
	mag = linear2db(mag.length())
	mag = (mag - mindb) / (maxdb - mindb)
	#modulate.a = 0.0 + mag
	freq += interval
	update()
