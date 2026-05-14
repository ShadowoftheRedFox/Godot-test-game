class_name Inventory extends Node

## Number of flots the inventory has. each slors can contain items_per_slot items.
@export var size: Vector2i = Vector2i(5, 2)
## Number of items per slot
@export var items_peer_slot: int = 100
## Items currently in the inventory
@export var items: Array[InventoryItem] = []
## Array of same size then items, tels how many item there is on the same index
@export var items_number: Array[int] = []

## True if the inventory is editable by the player interractions
## (such as his own inventory or a chest), otherwise only by scripts
@export var player_editable: bool = true
## True if you can add new items in it
@export var temporary: bool = false

func  _init() -> void:
	items.resize(size.x * size.y)
	items_number.resize(size.x * size.y)
