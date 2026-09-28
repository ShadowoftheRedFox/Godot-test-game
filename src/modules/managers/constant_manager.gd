## Only contains constant to fetch
class_name ConstantManager

## The game name.
const GAME_NAME: StringName = &"WTFisTHIS"

## The name of the mod that reprensents the game core.
const CORE_MOD_NAME: StringName = &"core"

## Folder containing all the item resources.
const ITEM_FOLDER: String = "res://resources/items/"
const BUILDING_FOLDER: String = "res://resources/building/"

const SCHEMA_FOLDER_PATH: String = "res://resources/schemas/"
const ITEM_SCHEMA_PATH: String = "item.json"
## This schema is loaded on init from the schema file in ITEM_SCHEMA_PATH.
static var ITEM_SCHEMA: String = ''

func _init() -> void:
	var schemas: FileUtils = FileUtils.new(SCHEMA_FOLDER_PATH)
	assert(schemas.exists(ITEM_SCHEMA_PATH), "There is not item schema defined")
	ITEM_SCHEMA = schemas.read(ITEM_SCHEMA_PATH)
	assert(!ITEM_SCHEMA.is_empty(), "Failed to read the item schema")
