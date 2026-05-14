class_name InventorySlot extends Node

## The texture rect that will show the items.
@onready var _visual: TextureRect = $Panel/Visual
## The inner texture of the _visual node
var _texture: ImageTexture = null

## Item contained inside the slot
var _item: InventoryItem = null
## Position inside the inventory
var _pos_in_inventory: Vector2i = Vector2i.ZERO
## Reference to the inventory that own this slot
var _inventory: Inventory = null

func _ready() -> void:
	assert(_inventory != null, "inventory reference is null")
	assert(_pos_in_inventory.x * _pos_in_inventory.y >= 0, "position in inventory is not positive")
	
	_texture = ImageTexture.new()
	_texture.draw_rect(_texture.get_rid(), Rect2(0.0, 0.0, 50.0, 50.0), false)
	_visual.texture = _texture
	_update_visual()

## Return true if the slot has an item inside
func has_item() -> bool:
	return _item != null

## Put an item inside, return true if the operation succeeded,
## false otherwise (an item is inside, or inventory is locked).
func set_item(item: InventoryItem, player_interaction: bool = true) -> bool:
	if has_item() or (not _inventory.player_editable and player_interaction):
		return false
	_item = item
	_update_visual.call_deferred()
	return true

## Remove the item from the slot, and returns it. If no item,
## it returns null.
func remove_item() -> InventoryItem:
	var temp: InventoryItem = _item
	_item = null
	_update_visual.call_deferred()
	return temp

## Update the visual of the slot.
func _update_visual() -> void:
	if not is_node_ready():
		return
	
	if has_item():
		_texture.set_image(_item.item_image)
	else:
		_texture.set_image(null)
