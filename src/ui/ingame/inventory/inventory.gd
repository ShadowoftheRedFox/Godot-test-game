class_name PlayerInventory extends MarginContainer
const INVENTORY_SLOT: PackedScene = preload("uid://dnsinxvoqcmqu")

## Grid where the inventory slots are.
@onready var grid_container: GridContainer = %GridContainer

## Reference to the inventory.
@export var inventory: Inventory = null

func _ready() -> void:
	# set grid columns
	grid_container.columns = inventory.size.x

	# build the slots with the same inventory size
	# if this is a toolbar
	if self is PlayerToolbar:
		# build only the last bar of the inventory
		for x: int in inventory.size.x:
			var slot: InventorySlot = INVENTORY_SLOT.instantiate()
			slot._inventory = inventory
			slot._pos_in_inventory = Vector2i(x, inventory.size.y - 1)
			grid_container.add_child(slot)
			slot.gui_input.connect(_on_gui_input.bind(slot))
	
		# focus the first slot
		(self as PlayerToolbar).focus_to(0)
	else:
		for y: int in inventory.size.y - 1:
			for x: int in inventory.size.x:
				var slot: InventorySlot = INVENTORY_SLOT.instantiate()
				slot._inventory = inventory
				slot._pos_in_inventory = Vector2i(x, y)
				grid_container.add_child(slot)
				slot.gui_input.connect(_on_gui_input.bind(slot))

## Listens for input on slot to create inventory interactions
@warning_ignore("unused_parameter")
func _on_gui_input(event: InputEvent, slot: InventorySlot) -> void:
	if slot == null:
		return
	# TODO drag and drop: move item
	# TODO drag and drop outside: drop items

	pass

## Stop processing when not visible
func _on_visibility_changed() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if visible else Node.PROCESS_MODE_DISABLED
