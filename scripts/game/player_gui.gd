class_name PlayerGUI extends MarginContainer
const INVENTORY_SLOT: PackedScene = preload("uid://dnsinxvoqcmqu")

## Grid where the inventory slots are.
@onready var grid_container: GridContainer = %GridContainer

## Reference to the player inventory.
@export var _player_inventory: Inventory = null

func _ready() -> void:	
	# set grid columns
	grid_container.columns = _player_inventory.size.x
	
	## build the slots with the same _player_inventory size
	for y: int in _player_inventory.size.y:
		for x: int in _player_inventory.size.x:
			var slot: InventorySlot = INVENTORY_SLOT.instantiate()
			slot._inventory = _player_inventory
			slot._pos_in_inventory = Vector2i(x, y)
			grid_container.add_child(slot)
			
			print("added slot " + str(y*_player_inventory.size.x + x))
