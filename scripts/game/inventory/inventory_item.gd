class_name InventoryItem extends Resource

## Class of the item, to have different behavior
enum ItemClass {
	UNSCPECIFIED,
	BUILDING,
	TOOL
}

## Rarity of the item, it will whange its spawn rate.
## Unspecified means it doesn't spawn
enum ItemRarity {
	UNSCPECIFIED,
	
	COMMON, 
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	MYTHIC,
	GODLIKE,
	UNIQUE
}

## Name of the item
@export var item_name: String = ""
## Image displayed in inventory
@export var item_image: Image = null
## If the item can be placed in world, this scene is what will be instantiated
@export var item_physical: PackedScene = null
## Class of the item, to have different behavior
@export var item_class: ItemClass = ItemClass.UNSCPECIFIED
## Rarity of the item, it will whange its spawn rate. Unspecified means it doesn't spawn
@export var item_rarity: ItemRarity = ItemRarity.UNSCPECIFIED
# TODO item size and shape in inventory? 
