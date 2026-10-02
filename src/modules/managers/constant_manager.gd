## Only contains constant to fetch
class_name ConstantManager

func _init() -> void:
	_read_schemas()

## The game name.
const GAME_NAME: StringName = &"WTFisTHIS"

## The name of the mod that reprensents the game core.
const CORE_MOD_NAME: StringName = &"core"

#region Schemas
## Folder containing all the building resources.
const BUILDING_FOLDER: String = "res://resources/buildings/"
## Folder containing all the fluid resources.
const FLUID_FOLDER: String = "res://resources/fluids/"
## Folder containing all the item resources.
const ITEM_FOLDER: String = "res://resources/items/"

## Folder containing all the resource schemas.
const SCHEMA_FOLDER_PATH: String = "res://resources/schemas/"

## File name for the building schema.
const BUILDING_SCHEMA_PATH: String = "building.json"
## File name for the fluid schema.
const FLUID_SCHEMA_PATH: String = "fluid.json"
## File name for the item schema.
const ITEM_SCHEMA_PATH: String = "item.json"

## This schema is loaded on init from the schema file in BUILDING_SCHEMA_PATH.
static var BUILDING_SCHEMA: String = ''
## This schema is loaded on init from the schema file in FLUID_SCHEMA_PATH.
static var FLUID_SCHEMA: String = ''
## This schema is loaded on init from the schema file in ITEM_SCHEMA_PATH.
static var ITEM_SCHEMA: String = ''

func _read_schemas() -> void:
	# read the schemas folder
	var schemas: FileUtils = FileUtils.new(SCHEMA_FOLDER_PATH)
	assert(schemas.exists(ITEM_SCHEMA_PATH), "There is not item schema defined")
	# load each schemas
	BUILDING_SCHEMA = schemas.read(BUILDING_SCHEMA_PATH)
	assert(!BUILDING_SCHEMA.is_empty(), "Failed to read the building schema")
	FLUID_SCHEMA = schemas.read(FLUID_SCHEMA_PATH)
	assert(!FLUID_SCHEMA.is_empty(), "Failed to read the fluid schema")
	ITEM_SCHEMA = schemas.read(ITEM_SCHEMA_PATH)
	assert(!ITEM_SCHEMA.is_empty(), "Failed to read the item schema")
#endregion
