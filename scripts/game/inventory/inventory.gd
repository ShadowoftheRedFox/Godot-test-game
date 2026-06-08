class_name Inventory extends Node

## Emitted when items are updated on the given position
signal items_updated(position: int)

## Number of flots the inventory has. each slors can contain items_per_slot items.
@export var size: Vector2i = Vector2i(5, 2)
## Number of items per slot
@export var max_items_per_slot: int = 100
## Items currently in the inventory
@export var items: Array[InventoryItem] = []
## Array of same size then items, tels how many item there is on the same index
@export var amounts: Array[int] = []

## True if the inventory is editable by the player interractions
## (such as his own inventory or a chest), otherwise only by scripts
@export var player_editable: bool = true
## True if items can be added inside this inventory
@export var can_add: bool = true
## True if items can be removed from this inventory
@export var can_remove: bool = true

func _init(_size: Vector2i = Vector2i(5, 2), \
	_max_items_per_slot: int = 100, \
	_player_editable: bool = true, \
	_can_add: bool = true, \
	_can_remove: bool = true) -> void:
	# set values
	size = _size
	max_items_per_slot = _max_items_per_slot
	player_editable = _player_editable
	can_add = _can_add
	can_remove = _can_remove

	# prepare array for our size
	var total_size: int = size.x * size.y
	items.resize(total_size)
	items.fill(null)
	amounts.resize(total_size)
	amounts.fill(0)

## Add the given amount of the given item in the inventory in the first slots
## available. Return the amount that could not be added.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func add_item(item: InventoryItem, amount: int, position: int = 0) -> int:
	if amount <= 0:
		return 0
	if item == null:
		return amount
	print("adding " + item.item_name)

	# loop from position to the end of out array
	for i: int in range(position, items.size()):
		var current_item: InventoryItem = items[i]
		var current_amount: int = amounts[i]

		# if the slot is full, or not the same item, skip
		if current_amount >= max_items_per_slot || !item.equals(current_item):
			continue

		# calculate the space left in this slot
		var space_left: int = max_items_per_slot - current_amount

		# if there is anough space for our amount, add it and finish
		if space_left >= amount:
			amounts[i] += amount
			amount = 0
			break
		else:
			# fill the space left, and goes to the next slot
			amount -= space_left
			amounts[i] = max_items_per_slot

		# update our item in case it was null
		items[i] = item
		items_updated.emit(i)

	return amount

## Remove the given amount of item at the given position.
## Return the amount left that could not be removed at this position.
func remove_position(amount: int, position: int) -> int:
	if amount <= 0:
		return 0
	if position < 0 || size.x * size.y <= position:
		return amount

	# if more amount to remove than possible on this slot, calculate how much
	# is available in this slot
	var leftover: int = 0
	if amount > max_items_per_slot:
		leftover = amount - max_items_per_slot
		amount = max_items_per_slot

	# remove the max amount from this slot and add the leftovers
	return leftover + remove_item(items[position], amount)

## Remove the given amount of the given item in the inventory.
## Return the amount left that could not be removed.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func remove_item(item: InventoryItem, amount: int, position: int = 0) -> int:
	if amount <= 0:
		return 0
	if item == null \
	|| position < 0 \
	|| size.x * size.y <= position:
		return amount

	# loop from position to the end of out array
	for i: int in range(position, items.size()):
		var current_item: InventoryItem = items[i]
		var current_amount: int = amounts[i]

		# if the slot has no items, or a different one than required, skip
		if current_amount == 0 || !item.equals(current_item):
			continue

		# if more amount than the one to remove, empty the slot
		if current_amount >= amount:
			amounts[i] -= amount
			amount = 0
			items[i] = null
			break
		else: # otherwise reduce the amount
			amount -= current_amount
			amounts[i] = 0

		items_updated.emit(i)

	return amount


## Move item from the source position to the destination position.
## If items are differents, swap them.
## If items are the same, fill the destination until the maximum amount, and
## put the leftovers back at the source.
## Returns the amount of items moved.
func move_own_item(source: int, destination: int) -> int:
	return move_item(source, self , destination)

## Move item from the source position to the destination position of the given
## inventory.
## If items are differents, swap them.
## If items are the same, fill the destination until the maximum amount, and
## put the leftovers back at the source.
## Returns the amount of items moved.
func move_item(source: int, other: Inventory, destination: int) -> int:
	if other == null \
	|| source < 0 \
	|| destination < 0 \
	|| size.x * size.y <= source \
	|| other.size.x * other.size.y <= destination:
		return 0

	# get the items and amounts from both sides
	var item_source: InventoryItem = items[source]
	var amount_source: int = amounts[source]

	var item_destination: InventoryItem = other.items[source]
	var amount_destination: int = other.amounts[source]

	# if not amount to move, just return
	if amount_source == 0 && amount_destination == 0:
		return 0

	var amount_moved: int = 0

	# if same item, move the amount
	if item_source.equals(item_destination):
		# we get the minimum amount movabel on both sides
		var space_left: int = min(other.max_items_per_slot - amount_destination, max_items_per_slot - amount_source);

		# the move the source to teh destination
		other.amounts[destination] += space_left
		amounts[source] -= space_left

		# if we emptied the desination, remove items
		if amounts[source] == 0:
			items[source] = null

		amount_moved = space_left
	else: # otherwise swap items and amount
		other.items[destination] = item_source
		other.amounts[destination] = amount_source

		items[source] = item_destination
		amounts[source] = amount_destination

		amount_moved = amount_source + amount_destination

	# update both sides
	items_updated.emit(source)
	other.items_updated.emit(destination)

	return amount_moved

## Get the amount available of this item in the inventory.
func get_amount_of_item(item: InventoryItem) -> int:
	if item == null:
		return 0

	var res: int = 0
	for i: int in items.size():
		if items[i] != null and items[i].equals(item):
			res += amounts[i]
	return res
