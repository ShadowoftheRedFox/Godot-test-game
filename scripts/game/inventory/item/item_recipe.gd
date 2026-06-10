class_name ItemRecipe extends Resource

class Pair extends Resource:
	## How much of this item is needed to craft.
	@export_range(1, 1000, 1, "or_greater") var amount: int = 1
	## What item is needed to craft.
	@export var item: InventoryItem = null

enum CraftingRequirement {
	## Can be crafted anywhere
	NONE,
	## Can be crafted in the inventory
	INVENTORY,
	## Can be crafted with a table
	TABLE,
	## Can be smelted with a furnace
	FURNACE,
	## Can be forged in an anvil
	ANVIL
}

## The requirements to be met for using this recipe.
@export var requirements: Array[CraftingRequirement] = [CraftingRequirement.NONE]
## The amount and item necessary to craft.
@export var items: Array[Pair] = []
## The amount yielded by this recipe
@export_range(1, 1000, 1, "or_greater") var yielded_amount: int = 1
## Sub product of this recipe
@export var subproduct: Array[Pair] = []

## The amount of time it takes to craft or smelt. In seconds or in hits.
@export_range(0.0, 300.0, 0.5, "or_greater") var time_cost: float = 0
## The energy cost.
@export_range(0.0, 10000, 1, "or_greater") var energy_cost: int = 0

# TODO heated item?
