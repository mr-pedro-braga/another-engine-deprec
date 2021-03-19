extends Node
class_name Inventory

# How many stacks can fit in this inventory.
var STACK_SIZE = 4
var size: int = 5
var items:Array

func list():
	for i in range(items.size()):
		print(i, ". ", items[i].id, " x", items[i].count)

func give_item(id, count):
	var item = Item.new()
	item.id = id
	item.count = count
	pick_item(item)
	MenuCore.update_items()

func pick_item(item):
	for _k in range(item.count):
		add_item(item.id)

# Add an item. Returns 1 if there is not enough space for that item.
func add_item(item):
	var has_stack:bool=false
	var stack 
	for k in range(items.size()):
		if items[k] == null:
			break
		if items[k].id == item and items[k].count < STACK_SIZE:
			has_stack = true
			stack = items[k]
	if has_stack:
		stack.count+=1
		return 0
	if items.size() + 1 <= size:
		var new_stack = Item.new()
		new_stack.id = item
		new_stack.count = 1
		items.append(new_stack)
		return 0
	return 1
