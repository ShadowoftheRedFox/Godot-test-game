## The player inventory UI.
class_name PlayerMenuInventoryState extends MenuMachineState

const INVENTORY: PackedScene = preload("uid://b50byu54aqqsv")
const NAME: StringName = &"inventory"

var inventory_menu: PlayerInventory = null

func get_state_name() -> StringName:
	return NAME

func setup_menu() -> void:
	var temp: Node = INVENTORY.instantiate()
	if temp == null:
		printerr("Failed to load the inventory menu")
		disabled = true
		return
	if temp is not PlayerInventory:
		printerr("The provided scene is not a PlayerInventory")
		disabled = true
		return
	inventory_menu = temp
	inventory_menu.inventory = Global.player.inventory._inventory
	inventory_menu.visible = false
	Global.MAIN.ui_root.add_child(inventory_menu)

func remove_menu() -> void:
	inventory_menu.remove()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	inventory_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func exit() -> void:
	inventory_menu.visible = false

func handle_input(_event: InputEvent) -> void:
	var c: bool = Input.is_action_just_pressed("action_inventory")
	var p: bool = Input.is_action_just_pressed("action_pause")

	if p || c:
		finished.emit(PlayerMenuIdleState.NAME)
