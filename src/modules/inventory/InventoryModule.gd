## Manage inventory on a global scale
class_name InventoryModule

## The current inventory slot being hovered
## Slots will manage this themselves
var currently_hovered_slot: InventorySlot = null

## Internal ID counter to get unique ID for slots and inventories
var _id: int = 0

## Get a unique ID
func get_id() -> int:
	_id+=1
	return _id
