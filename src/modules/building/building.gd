@abstract class_name Building extends Resource

## The category of the building.
## Some category will call specific functions and/or do specific actions.
enum BuildingCategory {
	## No specific category. The default value.
	UNCATEGORIZED,
	## Proction building (resources, electricity...)
	PRODUCTION,
	## Storage building (items, fluids...)
	STORAGE,
	## Base buildings (walls, floors, doors...)
	BUILDING,
	## Decoration buildings
	DECORATION,
	## Transportation buildings (trains, conveyor, pipes...)
	TRANSPORTATION,
}

## The status of the building, if it can produce something.
enum BuildingStatus {
	## Disabled, by either the player or electricity requirements.
	DISABLED,
	## Paused, the items requirements are not meet to run.
	PAUSED,
	## Running, everything is OK.
	RUNNING,
	## Running and is boosted.
	BOOSTED
}

@export_group("General" , "building_")
## The name of the building.
@export var building_name: String = ""
## The category of the building.
## E.g.: Transportation, Decoration...
@export var building_category: BuildingCategory = BuildingCategory.UNCATEGORIZED
## The group the building belongs to in the category.
## E.g.: Transportation -> Conveyor, Decoration -> Wall
@export var building_group: String = ""
## Mesh of the building.
@export var building_mesh: Mesh = null
## Physical scene for this building.
@export var building_physical: PackedScene = null

## Recipes for placing/destroying this building.
@export var recipes: Array[ItemRecipe] = []

## Whether or not this item is visible in the building menu.
@abstract func visible_in_building_menu() -> bool

## If this building uses electricty, returns the position where the cables
## should conect to it.
@abstract func get_electricity_connector_position() -> Vector3
