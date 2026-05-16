class_name InventorySlot extends Node

## The panel that shows the slot
@onready var _panel: Panel = $Panel
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
	
	# create a style override for the pannel for singular slot color control
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	# set default values 
	stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	stylebox.set_content_margin_all(5)
	stylebox.set_corner_radius_all(10)
	_panel.add_theme_stylebox_override("panel", stylebox)
	
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
	_panel.tooltip_text = item.item_name
	_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# TODO change bg coulour with item rarity
	_update_visual()
	return true

## Remove the item from the slot, and returns it. If no item,
## it returns null.
func remove_item() -> InventoryItem:
	var temp: InventoryItem = _item
	_item = null
	_panel.tooltip_text = ""
	_update_visual()
	_panel.mouse_default_cursor_shape = Control.CURSOR_CAN_DROP
	return temp

## Update the visual of the slot.
func _update_visual() -> void:
	# we set item related data here because _visual gets hidden when the item is removed
	if has_item():
		_visual.show()
		# TODO show a 3D image of the object, like in the editor with material
		_texture.update(_item.item_image)
		# set the tooltip color
		@warning_ignore("unsafe_call_argument")
		_visual.theme.set_color("font_color", "TooltipLabel", GameState.CONST.ITEM_CLASS_COLOR.get(_item.item_class, Color.WHITE))
		_visual.tooltip_text = _item.item_name
	else:
		_visual.hide()

func _on_hover(inside: bool) -> void:
	var stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel")
	# bg color with item rarity
	var color: Color = Color(0.1, 0.1, 0.1, 0.6)
	if inside:
		if has_item():
			color = GameState.CONST.ITEM_CLASS_COLOR.get(_item.item_rarity, Color(0.2, 0.2, 0.2, 0.6))
		else:
			color = Color(0.2, 0.2, 0.2, 0.6)
	stylebox.bg_color = color 

func _on_mouse_entered() -> void:
	_on_hover(true)

func _on_mouse_exited() -> void:
	_on_hover(false)
