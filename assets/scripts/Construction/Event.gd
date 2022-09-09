extends EventReference
class_name SceneEvent

#
#
# @ General Events Class!
#
# Useful for general events here and there.
#

export var event = ""
export var parameter = ""
export var arguments = []

# When this event gets activated
func _on_activated():
	get_node("/root/GameRoot/World/Scene").call("evt_" + event, self, parameter, arguments)
