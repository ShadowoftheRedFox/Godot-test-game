class_name PlayerInventory extends UIInventory

func setup_inventory_slots() -> void:
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
