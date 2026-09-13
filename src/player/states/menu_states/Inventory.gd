## The player inventory UI.
class_name PlayerMenuInventoryState extends MenuMachineState

const INVENTORY: PackedScene = preload("uid://b50byu54aqqsv")
var inventory_menu: PlayerInventory = null

func get_state_name() -> StringName:
	return "inventory"

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
	Global.MAIN.hud_root.add_child(inventory_menu)

func remove_menu() -> void:
	inventory_menu.queue_free()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	inventory_menu.visible = true

func exit() -> void:
	inventory_menu.visible = false

func handle_input(_event: InputEvent) -> void:
	var c: bool = Input.is_action_just_pressed("action_inventory")
	var p: bool = Input.is_action_just_pressed("action_pause")

	if p || c:
		finished.emit("idle")
