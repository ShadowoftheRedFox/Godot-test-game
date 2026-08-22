class_name InventorySlot extends Control

@export_range(10.0, 100.0) var slot_square_size: float = 80.0

## The panel that shows the slot
@onready var _panel: Panel = $Panel
## The control that will show the items.
@onready var _visual: SubViewportContainer = $Panel/Visual
## The subviewport to show the 3D object in 2D controls
@onready var _sub_viewport: SubViewport = $Panel/Visual/SubViewport
## Label to display the amount
@onready var _label: Label = $Panel/Label

## Position inside the inventory
var _pos_in_inventory: Vector2i = Vector2i.ZERO
## Actual index of the position in the inventory.
var _index: int = -1
## Reference to the inventory that own this slot
var _inventory: Inventory = null
## If the slot is currently focused (equiped/used)
var _focused: bool = false

func _ready() -> void:
	assert(_inventory != null, "inventory must not be null")
	assert(_pos_in_inventory.x * _pos_in_inventory.y >= 0 \
	 && _pos_in_inventory.x < _inventory.size.x \
	 && _pos_in_inventory.y < _inventory.size.y, \
	 "position in inventory is out of range")
	
	# add itself to the inventory
	_inventory._slots.append(self)
	
	# set the square size where it need to be
	var slot_size: Vector2 = Vector2(slot_square_size, slot_square_size)
	self.custom_minimum_size = slot_size
	self.size = slot_size
	_panel.custom_minimum_size = slot_size
	_panel.size = slot_size
	_visual.custom_minimum_size = slot_size
	
	# the scale of the subviewport container is 0.155 when the slot_size is 80
	# adapt for custom slot_size: 0.155 = 80/0.0019375
	var visual_scale: float = slot_square_size * 0.0019375
	_visual.scale = Vector2(visual_scale, visual_scale)
	_visual.position = Vector2(0, 0)

	# calculate the true index in advance
	_index = _pos_in_inventory.y * _inventory.size.x + _pos_in_inventory.x
	name = "slot" + str(_index)

	# listen to udpates
	_inventory.items_updated.connect(_on_item_updated)

	# create a style override for the pannel for singular slot color control
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	# set default values
	stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	stylebox.set_content_margin_all(5)
	stylebox.set_corner_radius_all(10)
	stylebox.border_blend = true
	_panel.add_theme_stylebox_override("panel", stylebox)

	_on_item_updated(_index)

func _get_item() -> InventoryItem:
	if _inventory.items.size() <= _index:
		return null
	return _inventory.items[_index]

func _get_amount() -> int:
	return _inventory.amounts[_index]

## Return true if the slot has an item inside
func _has_item() -> bool:
	return _get_item() != null

func _on_item_updated(_position: int) -> void:
	if _position != _index:
		return

	if _has_item():
		_set_item()
	else:
		_remove_item()

func _set_item() -> void:
	_panel.tooltip_text = _get_item().item_name
	_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_label.text = str(_get_amount())
	_update_visual()

func _remove_item() -> void:
	_panel.tooltip_text = ""
	_panel.mouse_default_cursor_shape = Control.CURSOR_CAN_DROP
	_label.text = ""
	_update_visual()

## Update the visual of the slot.
func _update_visual() -> void:
	_update_body_in_subviewport()
	if _has_item():
		_visual.show()
		# set the tooltip color
		@warning_ignore("unsafe_call_argument")
		_panel.theme.set_color("font_color", "TooltipLabel", InventoryItem.ITEM_CLASS_COLOR.get(_get_item().item_class, Color.WHITE))
		_panel.tooltip_text = _get_item().item_name
	else:
		@warning_ignore("unsafe_call_argument")
		_panel.theme.set_color("font_color", "TooltipLabel", Color.WHITE)
		_panel.tooltip_text = ""
		_visual.hide()

## Add or remove the visual in the subviewport
func _update_body_in_subviewport() -> void:
	const NODE_NAME: String = "SV_INVENTORY_ITEM"
	# find the node from name and free it
	if not _has_item():
		var node: Node = _sub_viewport.find_child(NODE_NAME, false, true)
		if node != null:
			node.queue_free()
		return

	# add a node with the correct mesh and name
	var minstance: MeshInstance3D = MeshInstance3D.new()
	minstance.mesh = _get_item().item_mesh
	minstance.name = NODE_NAME
	_sub_viewport.add_child(minstance)
	# TODO we don't need to move the mesh around, the camera is placed to see where it appears

func _on_hover(inside: bool) -> void:
	var stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel")
	# bg color with item rarity
	var color: Color = Color(0.1, 0.1, 0.1, 0.6)
	if inside:
		if _has_item():
			color = InventoryItem.ITEM_CLASS_COLOR.get(_get_item().item_rarity, Color(0.2, 0.2, 0.2, 0.6))
		else:
			color = Color(0.2, 0.2, 0.2, 0.6)
	stylebox.bg_color = color

func _on_mouse_entered() -> void:
	_on_hover(true)

func _on_mouse_exited() -> void:
	_on_hover(false)

func set_focus(focused: bool) -> void:
	_focused = focused
	var stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel")
	var border_width: int = 0
	var border_color: Color = Color.TRANSPARENT
	
	if focused:
		border_width = 3
		border_color = Color.CYAN
	
	stylebox.set_border_width_all(border_width)
	stylebox.border_color = border_color
