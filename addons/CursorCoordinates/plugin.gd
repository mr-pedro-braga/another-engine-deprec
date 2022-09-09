tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("res://addons/CursorCoordinates/plugin.tscn").instance()
	add_control_to_bottom_panel(dock, "Coordinates")

func _input(event):
	var scene_root = get_tree().get_edited_scene_root()
	if not scene_root:
		return
	if not scene_root.has_method("get_global_mouse_position"):
		return
	var mouse_coords = scene_root.get_global_mouse_position()
	var x = int(mouse_coords.x)
	var y = int(mouse_coords.y)
	dock.text = "Mouse: (" + str(x) + ", " + str(y) + ")" + "\nTile: (" + str(x/32) + ", " + str(y/32) + ")"

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
