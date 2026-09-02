class_name Inventory extends Resource

## Emitted when items are updated on the given position
signal items_updated(position: int)
## Emitted when the inventory's size changes.
signal size_changed()

## Number of flots the inventory has. each slors can contain items_per_slot items.
@export var size: Vector2i = Vector2i(5, 2)
## The size of the inventory as int.
var int_size: int = 0
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

## Internal references to the slots nodes of this inventory
@warning_ignore("unused_private_class_variable")
var _slots: Array[InventorySlot] = []

var _id: int = 0

func _init(_size: Vector2i = Vector2i(5, 2), \
	_max_items_per_slot: int = 100, \
	_player_editable: bool = true, \
	_can_add: bool = true, \
	_can_remove: bool = true) -> void:
	# get a unique ID
	_id = Global.IM.get_id()
	# set values
	size = _size
	max_items_per_slot = _max_items_per_slot
	player_editable = _player_editable
	can_add = _can_add
	can_remove = _can_remove
	set_size(size)

## Change the size of the inventory.
## If the new size is lower than the current one, it may need to drop items.
## Returns the amount of items dropped.
## New size must be bigger than 0.
func set_size(new_size: Vector2i) -> int:
	if new_size.x <= 0 || new_size.y <= 0:
		return 0

	var int_new_size: int = new_size.x * new_size.y
	if int_new_size >= int_size:
		int_size = int_new_size
		# prepare array for our size
		items.resize(int_size)
		amounts.resize(int_size)
		size_changed.emit()
		return 0

	var removed: int = 0
	for i: int in range(int_new_size, int_size):
		var item: InventoryItem = items[i]
		if item != null:
			var item_removed: int = remove_item(item, -1, i)
			removed += item_removed
			item.dropped(item_removed)

	for i: int in range(int_size, int_new_size, -1):
		_slots[i].queue_free()
		_slots.remove_at(i)

	# prepare array for our size
	items.resize(int_size)
	amounts.resize(int_size)
	size_changed.emit()

	return removed

## Add the given amount of the given item in the inventory in the first slots
## available. Return the amount that could not be added.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func add_item(item: InventoryItem, amount: int, position: int = 0) -> int:
	print("called add item")
	if amount <= 0:
		print("amount 0")
		return 0
	if item == null:
		print("item null")
		return amount

	# check if we already got an item
	var last_item: int = get_last_index_of_item(item, true)
	if last_item > position:
		print("last item")
		# if yes, add at this slot first
		return add_item(item, amount, last_item)

	print("position: ", position, " size: ", int_size)
	# loop from position to the end of out array
	for i: int in range(position, int_size):
		var current_item: InventoryItem = items[i]
		var current_amount: int = amounts[i]

		# if the slot is full, or not the same item, skip
		if current_amount >= max_items_per_slot || (current_item != null && !item.equals(current_item)):
			print("full or not same item")
			continue

		# calculate the space left in this slot
		var space_left: int = max_items_per_slot - current_amount
		print("space left ", space_left)
		# if there is enough space for our amount, add it and finish
		if space_left >= amount:
			amounts[i] += amount
			amount = 0
		else:
			# fill the space left, and goes to the next slot
			amounts[i] = max_items_per_slot
			amount -= space_left

		# update our item in case it was null
		items[i] = item
		items_updated.emit(i)

		if amount == 0:
			print("zero")
			return 0
	print("end return")
	return amount

## Remove all items from the inventory.
func clear() -> void:
	for i: int in range(0, int_size):
		items[i] = null
		amounts[i] = 0
		items_updated.emit(i)

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

## Remove the given item in the inventory.
## If amount is -1 (the default), remove all of this items from this inventory.
## Return the amount left that could not be removed.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func remove_item(item: InventoryItem, amount: int = -1, position: int = 0) -> int:
	if amount != -1 && amount <= 0:
		return 0
	if item == null \
	|| position < 0 \
	|| size.x * size.y <= position:
		return max(1, amount)

	# loop from position to the end of out array
	for i: int in range(position, int_size):
		var current_item: InventoryItem = items[i]
		var current_amount: int = amounts[i]

		# if the slot has no items, or a different one than required, skip
		if current_amount == 0 || !item.equals(current_item):
			continue

		# if amout is -1, remove all items regardless
		if amount == -1:
			amounts[i] = 0
			items[i] = null
		# if more amount than the one to remove, empty the slot
		elif current_amount >= amount:
			amounts[i] -= amount
			amount = 0
			# set to null if we emptied the slot
			if amounts[i] == 0:
				items[i] = null
		else: # otherwise reduce the amount
			amount -= current_amount
			amounts[i] = 0
			items[i] = null

		items_updated.emit(i)

		# stop when amount reaches 0 (this intentionnaly lets amount == -1 continue)
		if amount == 0:
			return 0

	return amount

## Move item from the source position to the destination position.
## If items are differents, swap them.
## If items are the same, fill the destination until the maximum amount, and
## put the leftovers back at the source.
## Returns the amount of items moved.
func move_own_item(source: int, destination: int) -> int:
	return move_item(source, self, destination)

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

	var item_destination: InventoryItem = other.items[destination]
	var amount_destination: int = other.amounts[destination]

	# if not amount to move, or same slot, just return
	if amount_source <= 0 && amount_destination <= 0 \
		|| (other._id == _id && source == destination):
		return 0

	var amount_moved: int = 0

	# if same item, move the amount
	if item_source != null && item_source.equals(item_destination):
		# we get the amount movable on both sides, then the minimum between the two
		# it prevent a bigger inventory from overflowing a smaller one
		var space_left: int = min(other.max_items_per_slot - amount_destination, max_items_per_slot - amount_source);
		# then we make sure the amount moving isn't higher than the space left
		var amount_to_move: int = clampi(amount_source, 0, space_left)

		# the move the source to the destination
		other.amounts[destination] += amount_to_move
		amounts[source] -= amount_to_move

		# if we emptied the desination, remove items
		if amounts[source] <= 0:
			items[source] = null

		amount_moved = amount_to_move
	elif item_source != null && amount_source > 0:
		# otherwise swap items and amount if source is not null
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
	for i: int in int_size:
		if items[i] != null and items[i].equals(item):
			res += amounts[i]
	return res

## Get the last index of the item given in the inventoy.
## Returns -1 if not found, or if item is null.
## If free is true, returns the first found slot that isn't full.
func get_last_index_of_item(item: InventoryItem, free: bool = false) -> int:
	if item == null:
		return -1

	for i: int in range(int_size - 1, -1, -1):
		if items[i] != null && items[i].equals(item) && (!free || amounts[i] != max_items_per_slot):
			return i
	return -1

## Check if the given slot is registered in the inventory slots.
## Return true if it is registered, false otherwise.
func has_slot(slot: InventorySlot) -> bool:
	if slot == null:
		return false
	return has_slot_id(slot._id)

## Check if the given slot's ID is registered in the inventory slots.
## Return true if it is registered, false otherwise.
func has_slot_id(id: int) -> bool:
	for slot: InventorySlot in _slots:
		if slot._id == id:
			return true
	return false

## Add a slot to the registered inventory slots.
## Only added if the slot doesn't already exists.
func add_slot(slot: InventorySlot) -> void:
	if slot == null || has_slot_id(slot._id):
		return

	_slots.append(slot)

## Remove the slot from the registered inventory slots.
func remove_slot(slot: InventorySlot) -> void:
	if slot == null:
		return
	remove_slot_id(slot._id)

## Remove the slot whose ID matches the given ID, from the registered inventory slots.
func remove_slot_id(slot_id: int) -> void:
	for i: int in range(_slots.size()):
		if _slots.get(i)._id == slot_id:
			_slots.remove_at(i)
