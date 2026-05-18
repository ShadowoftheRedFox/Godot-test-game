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

## Alpha value for all item rarity colors
const ITEM_RARITY_COLOR_ALPHA: float = 0.6

## Color mapping to rarity for item background
const ITEM_RARITY_COLOR: Dictionary[ItemRarity, Color] = {
	# Color.HOT_PINK,
	ItemRarity.UNSCPECIFIED: Color(1, 0.4117647, 0.7058824, ITEM_RARITY_COLOR_ALPHA),
	# Color.WHITE,
	ItemRarity.COMMON: Color(1, 1, 1, ITEM_RARITY_COLOR_ALPHA),
	# Color.SKY_BLUE,
	ItemRarity.UNCOMMON: Color(0.5294118, 0.80784315, 0.92156863, ITEM_RARITY_COLOR_ALPHA),
	# Color.BLUE,
	ItemRarity.RARE: Color(0, 0, 1, ITEM_RARITY_COLOR_ALPHA),
	# Color.PURPLE,
	ItemRarity.EPIC: Color(0.627451, 0.1254902, 0.9411765, ITEM_RARITY_COLOR_ALPHA),
	# Color.GOLDENROD,
	ItemRarity.LEGENDARY: Color(0.85490197, 0.64705884, 0.1254902, ITEM_RARITY_COLOR_ALPHA),
	# Color.RED,
	ItemRarity.MYTHIC: Color(1, 0, 0, ITEM_RARITY_COLOR_ALPHA),
	# Color.DARK_RED,
	ItemRarity.GODLIKE: Color(0.54509807, 0, 0, ITEM_RARITY_COLOR_ALPHA),
	# Color.GREEN,
	ItemRarity.UNIQUE: Color(0, 1, 0, ITEM_RARITY_COLOR_ALPHA),
}

## Color mapping to rarity for item name
const ITEM_CLASS_COLOR: Dictionary[ItemClass, Color] = {
	ItemClass.UNSCPECIFIED: Color.WHITE,
	ItemClass.BUILDING: Color.SKY_BLUE,
	ItemClass.TOOL: Color.YELLOW,
}

## Name of the item
@export var item_name: String = ""
## Mesh of the item
@export var item_mesh: Mesh = null
## If the item can be placed in world, this scene is what will be instantiated
@export var item_physical: PackedScene = null
## Class of the item, to have different behavior
@export var item_class: ItemClass = ItemClass.UNSCPECIFIED
## Rarity of the item, it will whange its spawn rate. Unspecified means it doesn't spawn
@export var item_rarity: ItemRarity = ItemRarity.UNSCPECIFIED
# TODO item size and shape in inventory? 
