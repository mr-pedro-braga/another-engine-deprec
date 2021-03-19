extends Node

# Menus

### The menu currently being interacted with
var focused_menu = ""
### The character the menu is about
var current_inspecting_character:String = "claire"
### All the opened menus, for record
var menu_open = {
	"item": false
}
## If in a main menu (uses the top and bottom black bars)
var in_mmenu = false

### Toggles a certain menu
func toggle(menu:String):
	menu_open["menu"] = !menu_open["menu"]

### Sets the state of a certain menu
func set_open(menu:String, open:bool):
	menu_open[menu] = open

### Check if a menu is open
func is_open(menu:String):
	return menu_open[menu]

## Open and Close Menus by clicking keys!
func _process(_delta):
	
	if not Gameplay.game_running:
		return
	if Input.is_action_just_pressed("item"):
		if not is_open("item") and not Gameplay.in_ui and not Gameplay.in_dialog:
			focused_menu = "item"
			Gameplay.in_ui = true
			set_open("item", true)
			Gameplay.playable_character_node.stop()
			get_node("/root/GameRoot/HUD/UIs/InventoryAnim").play("hotbar_in")
			get_node("/root/GameRoot/HUD/black_bars").play("dialog_slide_in")
			get_node("/root/GameRoot/HUD/black_bars_top").play("menu2_in")
			AudioServer.set_bus_volume_db(1, -10)
			#Gameplay.update_zoom(Gameplay.zoom*1.1)
			AudioManager.play_sound("SFX_Menu_Select")
		else:
			Gameplay.in_ui = false
			set_open("item", false)
			get_node("/root/GameRoot/HUD/UIs/InventoryAnim").play("hotbar_out")
			get_node("/root/GameRoot/HUD/black_bars").play("dialog_slide_out")
			get_node("/root/GameRoot/HUD/black_bars_top").play("menu2_out")
			AudioServer.set_bus_volume_db(1, 0)
			#Gameplay.update_zoom(Gameplay.zoom/1.1)
			AudioManager.play_sound("SFX_Menu_Cancel")
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

# Inventories

### All the inventories PER CHARACTER.
var inventories:Dictionary = {
	"claire": Inventory.new()
} setget update_items

func show_hotbar():
	get_node("/root/GameRoot/HUD/UIs/InventoryAnim").play("hotbar_in")
func hide_hotbar():
	get_node("/root/GameRoot/HUD/UIs/InventoryAnim").play("hotbar_out")

### Updates the items visualization for the current inspecting character
func update_items(_value={}):
	var v = true
	var inventory_display = get_node("/root/GameRoot/HUD/UIs/Inventory")
	var item 
	var slot
	for i in range(5):
		slot = inventory_display.get_child(i)
		if i >= inventories[current_inspecting_character].items.size():
			v = false
		item = slot.get_child(0)
		if(v):
			item.visible = true
			item.play(inventories[current_inspecting_character].items[i].id)
			item.get_child(0).frame = inventories[current_inspecting_character].items[i].count - 1
			continue
		item.visible = false
