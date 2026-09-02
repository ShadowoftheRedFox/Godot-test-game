## Mirror the resource Inventory, by as a Node.
class_name InventoryNode extends Node

## INternak inventory used for mirroring a real inventory.
var _inventory: Inventory = null

## Number of flots the inventory has. each slors can contain items_per_slot items.
@export var size: Vector2i = Vector2i(5, 3)
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

func _ready() -> void:
	if _inventory == null:
		_inventory = Inventory.new(size, max_items_per_slot, player_editable, can_add, can_remove)
	else:
		_inventory.set_size(size)
		_inventory.max_items_per_slot = max_items_per_slot
		_inventory.player_editable = player_editable
		_inventory.can_add = can_add
		_inventory.can_remove = can_remove

	if items.size() > 0:
		for i: int in range(items.size()):
			_inventory.add_item(items[i], amounts[i] if amounts.size() < i else 1)

## Add the given amount of the given item in the inventory in the first slots
## available. Return the amount that could not be added.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func add_item(item: InventoryItem, amount: int, position: int = 0) -> int:
	return _inventory.add_item(item, amount, position)

## Remove all items from the inventory.
func clear() -> void:
	_inventory.clear()

## Remove the given amount of item at the given position.
## Return the amount left that could not be removed at this position.
func remove_position(amount: int, position: int) -> int:
	return _inventory.remove_position(amount, position)

## Remove the given item in the inventory.
## If amount is -1 (the default), remove all of this items from this inventory.
## Return the amount left that could not be removed.
## Position is optional. If supplied, will try to remove item starting from
## this position.
func remove_item(item: InventoryItem, amount: int = -1, position: int = 0) -> int:
	return _inventory.remove_item(item, amount, position)


## Move item from the source position to the destination position.
## If items are differents, swap them.
## If items are the same, fill the destination until the maximum amount, and
## put the leftovers back at the source.
## Returns the amount of items moved.
func move_own_item(source: int, destination: int) -> int:
	return _inventory.move_item(source, _inventory, destination)

## Move item from the source position to the destination position of the given
## inventory.
## If items are differents, swap them.
## If items are the same, fill the destination until the maximum amount, and
## put the leftovers back at the source.
## Returns the amount of items moved.
func move_item(source: int, other: Inventory, destination: int) -> int:
	return _inventory.move_item(source, other, destination)

## Get the amount available of this item in the inventory.
func get_amount_of_item(item: InventoryItem) -> int:
	return _inventory.get_amount_of_item(item)

## Get the last index of the item given in the inventoy.
## Returns -1 if not found, or if item is null.
## If free is true, returns the first found slot that isn't full.
func get_last_index_of_item(item: InventoryItem, free: bool = false) -> int:
	return _inventory.get_last_index_of_item(item, free)


## Check if the given slot is registered in the inventory slots.
## Return true if it is registered, false otherwise.
func has_slot(slot: InventorySlot) -> bool:
	return _inventory.has_slot(slot)

## Check if the given slot's ID is registered in the inventory slots.
## Return true if it is registered, false otherwise.
func has_slot_id(id: int) -> bool:
	return _inventory.has_slot_id(id)

## Add a slot to the registered inventory slots.
## Only added if the slot doesn't already exists.
func add_slot(slot: InventorySlot) -> void:
	_inventory.add_slot(slot)

## Remove the slot from the registered inventory slots.
func remove_slot(slot: InventorySlot) -> void:
	_inventory.remove_slot(slot)

## Remove the slot whose ID matches the given ID, from the registered inventory slots.
func remove_slot_id(slot_id: int) -> void:
	_inventory.remove_slot_id(slot_id)
