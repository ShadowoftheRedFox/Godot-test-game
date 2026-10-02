## The game loader, that starts at the game initialisation to load all the assets needed.
class_name GameLoader extends MultiStepLoader

var _items_loading_step: Step
var _fluids_loading_step: Step
var _building_loading_step: Step

func _init() -> void:
	_items_loading_step = Step.new("Loading items", FolderLoader.new(ConstantManager.ITEM_FOLDER, _threader_read_file.bind(_read_item_content), FolderReader.FilePattern.new("", ".json")))
	_fluids_loading_step = Step.new("Loading fluids", FolderLoader.new(ConstantManager.FLUID_FOLDER, _threader_read_file.bind(_read_fluid_content), FolderReader.FilePattern.new("", ".json")))
	_building_loading_step = Step.new("Loading buildings", FolderLoader.new(ConstantManager.BUILDING_FOLDER, _threader_read_file.bind(_read_building_content), FolderReader.FilePattern.new("", ".json")))

	_steps.append(_items_loading_step)
	_steps.append(_fluids_loading_step)
	_steps.append(_building_loading_step)

func _threader_read_file(parent_folder: String, file_name: String, definition_reader: Callable) -> StringName:
	var file: FileUtils = FileUtils.new(parent_folder)
	var content: String = file.read(file_name)
	return definition_reader.call(content)

func _read_item_content(content: String) -> StringName:
	var definition: ItemDefinition = ItemDefinition.parse(ConstantManager.CORE_MOD_NAME, content)
	ItemRegistry.get_self().add_item(definition)
	return definition.get_id()

func _read_fluid_content(content: String) -> StringName:
	var definition: FluidDefinition = FluidDefinition.parse(ConstantManager.CORE_MOD_NAME, content)
	FluidRegistry.get_self().add_fluid(definition)
	return definition.get_id()

func _read_building_content(content: String) -> StringName:
	var definition: BuildingDefinition = BuildingDefinition.parse(ConstantManager.CORE_MOD_NAME, content)
	BuildingRegistry.get_self().add_building(definition)
	return definition.get_id()

func load() -> void:
	super.load()
