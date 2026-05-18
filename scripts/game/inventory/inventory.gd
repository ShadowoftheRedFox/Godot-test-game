class_name Inventory extends Node

signal _add_slot(slot: InventorySlot)

## Add the amount of item to the inventory. There can be loss.
## Use function `add_item_loss` to get the amount of leftovers.
signal add_item(item: InventoryItem, amount: int)
## Remove the amount of item from the inventory. There can be less than required.
## Use function `remove_item_real` to get the amount removed.
signal remove_item(item: InventoryItem, amount: int)

## Number of flots the inventory has. each slors can contain items_per_slot items.
@export var size: Vector2i = Vector2i(5, 2)
## Number of items per slot
@export var max_items_per_slot: int = 100
## Items currently in the inventory
@export var items: Array[InventoryItem] = []
## Array of same size then items, tels how many item there is on the same index
@export var items_amount: Array[int] = []
## list of slots
var _slots: Array[InventorySlot] = []

## True if the inventory is editable by the player interractions
## (such as his own inventory or a chest), otherwise only by scripts
@export var player_editable: bool = true
## True if you can add new items in it
@export var temporary: bool = false

func _init() -> void:
	items.resize(size.x * size.y)
	items.fill(null)
	items_amount.resize(size.x * size.y)
	items_amount.fill(0)

	_add_slot.connect(_on_add_slot)
	add_item.connect(add_item_loss)
	remove_item.connect(remove_item_real)

func _on_add_slot(slot: InventorySlot) -> void:
	_slots.push_back(slot)
	# skip until all slots are added
	if _slots.size() != items.size():
		return

	# sort slots row by row
	_slots.sort_custom(_sort_slots)

	# set the correct slots with the prefiled items
	for i: int in _slots.size():
		if items[i] != null:
			_slots[i]._item_updated.emit()

func _sort_slots(a: InventorySlot, b: InventorySlot) -> bool:
	var u: Vector2i = a._pos_in_inventory
	var v: Vector2i = b._pos_in_inventory
	var l: int = size.x
	return u.y * l + u.x < v.y * l + v.x

## Add items to the first available slot, in as many slots as needed.
## Returns the amount of item left to add.
func add_item_loss(_item: InventoryItem, _amount: int) -> int:
	# invalid parameters
	if _item == null or _amount <= 0:
		return max(0, _amount)
	for i: int in items.size():
		var item: InventoryItem = items[i]
		var amount: int = items_amount[i]
		# if slot empty, just set it
		if item == null:
			items[i] = _item
			return _add_to_slot(i, _item, _amount)
		# if slot has the same item and has enough space
		if item != null and item.item_name == _item.item_name and amount < max_items_per_slot:
			items[i] = _item
			return _add_to_slot(i, _item, _amount)
	# leftovers
	return _amount

func _add_to_slot(i: int, _item: InventoryItem, _amount: int, _strict: bool = false) -> int:
	# invalid parameters
	if _item == null or _amount <= 0:
		return max(0, _amount)
	var s: InventorySlot = _slots[i]
	var amount: int = items_amount[i]
	# add as much item as possible
	if amount + _amount >= max_items_per_slot:
		items_amount[i] = max_items_per_slot
		s._item_updated.emit()
		# if strict, return leftovers
		if _strict:
			return amount + _amount - max_items_per_slot
		# call itself with the rest of the items
		return add_item_loss(_item, amount + _amount - max_items_per_slot)
	else:
		items_amount[i] += _amount
		s._item_updated.emit()
		return 0

## Add items to the first available slot, in only one slot, starting at the given index (default: 0).
## Returns the amount of item left to add.
func add_item_loss_strict(_item: InventoryItem, _amount: int, _start: int = 0) -> int:
	# invalid parameters
	if _item == null or _amount <= 0:
		return max(0, _amount)
	# invalid start
	if _start >= items.size() or _start < 0:
		return _amount
	# add to slot strictly
	for i: int in range(_start, items.size()):
		var item: InventoryItem = items[i]
		var amount: int = items_amount[i]
		# if slot empty, just set it
		if item == null:
			items[i] = _item
			return _add_to_slot(i, _item, _amount, true)
		# if slot has the same item and has enough space
		if item != null and item.item_name == _item.item_name and amount < max_items_per_slot:
			items[i] = _item
			return _add_to_slot(i, _item, _amount, true)
	# leftovers
	return _amount

## Get the amount available of this item in the inventory
func get_amount_of_item(_item: InventoryItem) -> int:
	# null parameter
	if _item == null:
		return 0
	var res: int = 0
	for i: int in items.size():
		if items[i] != null and items[i].item_name == _item.item_name:
			res += items_amount[i]
	return res

## Remove the given amount of item from the inventory, starting at the given index (default: 0).
## Returns the actual amount removed.
func remove_item_real(_item: InventoryItem, _amount: int, _start: int = 0) -> int:
	# invalid parameters
	if _item == null or _amount <= 0 or _start >= items.size() or _start < 0:
		return 0
	var res: int = 0
	for i: int in range(_start, items.size()):
		if items[i] != null and items[i].item_name == _item.item_name:
			# more to remove than available
			if _amount > items_amount[i]:
				res += items_amount[i]
				_amount -= items_amount[i]
				items_amount[i] = 0
				_slots[i]._item_updated.emit()
				continue
			# less to remove than available (or equal)
			if _amount <= items_amount[i]:
				res += _amount
				items_amount[i] -= _amount
				_slots[i]._item_updated.emit()
				break
	return res

# TODO move items from slot A to B if w ever need it lul
# with index, it's removing the amount at A and adding the same amount at B
# if surplus, do we add after B or do we keep it at A?
