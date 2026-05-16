## Only contains constant to fetch
class_name ConstantManager

## Alpha value for all item rarity colors
const ITEM_RARITY_COLOR_ALPHA: float = 0.6

## Color mapping to rarity for item background
const ITEM_RARITY_COLOR: Dictionary[InventoryItem.ItemRarity, Color] = {
	# Color.HOT_PINK,
	InventoryItem.ItemRarity.UNSCPECIFIED: Color(1, 0.4117647, 0.7058824, ITEM_RARITY_COLOR_ALPHA),
	# Color.WHITE,
	InventoryItem.ItemRarity.COMMON: Color(1, 1, 1, ITEM_RARITY_COLOR_ALPHA),
	# Color.SKY_BLUE,
	InventoryItem.ItemRarity.UNCOMMON: Color(0.5294118, 0.80784315, 0.92156863, ITEM_RARITY_COLOR_ALPHA),
	# Color.BLUE,
	InventoryItem.ItemRarity.RARE: Color(0, 0, 1, ITEM_RARITY_COLOR_ALPHA),
	# Color.PURPLE,
	InventoryItem.ItemRarity.EPIC: Color(0.627451, 0.1254902, 0.9411765, ITEM_RARITY_COLOR_ALPHA),
	# Color.GOLDENROD,
	InventoryItem.ItemRarity.LEGENDARY: Color(0.85490197, 0.64705884, 0.1254902, ITEM_RARITY_COLOR_ALPHA),
	# Color.RED,
	InventoryItem.ItemRarity.MYTHIC: Color(1, 0, 0, ITEM_RARITY_COLOR_ALPHA),
	# Color.DARK_RED,
	InventoryItem.ItemRarity.GODLIKE: Color(0.54509807, 0, 0, ITEM_RARITY_COLOR_ALPHA),
	# Color.GREEN,
	InventoryItem.ItemRarity.UNIQUE: Color(0, 1, 0, ITEM_RARITY_COLOR_ALPHA),
}

## Color mapping to rarity for item name
const ITEM_CLASS_COLOR: Dictionary[InventoryItem.ItemClass, Color] = {
	InventoryItem.ItemClass.UNSCPECIFIED: Color.WHITE,
	InventoryItem.ItemClass.BUILDING: Color.SKY_BLUE,
	InventoryItem.ItemClass.TOOL: Color.YELLOW,
}
