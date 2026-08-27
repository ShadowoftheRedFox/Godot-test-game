class_name PlayerToolbar extends PlayerInventory

## The index of the currently foxued (equipped) slot from the toolbar
var focused_slot: int  = 0

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	var e: InputEventMouseButton = event
	if !e.is_pressed():
		return

	if e.button_index == MOUSE_BUTTON_WHEEL_UP:
		focused_slot += 1
	if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		focused_slot -= 1
	
	if focused_slot < 0:
		focused_slot = inventory.size.x - 1
	else:
		focused_slot = focused_slot % inventory.size.x
	
	focus_to(focused_slot)

## Change the focus to the wanted slot
func focus_to(slot: int) -> void:
	focused_slot = clampi(slot, 0, inventory.size.x)
	
	for i: InventorySlot in inventory._slots:
		i.set_focus(i._pos_in_inventory.x == slot)
