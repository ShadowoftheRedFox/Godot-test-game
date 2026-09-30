## The game loader, that starts at the game initialisation to load all the assets needed.
class_name GameLoader extends MultiStepLoader

var _items_loading_step: Step

func _init() -> void:
	_items_loading_step = Step.new("Loading items", FolderLoader.new(ConstantManager.ITEM_FOLDER, _threader_read_item_file, FolderReader.FilePattern.new("", ".json")))
	_steps.append(_items_loading_step)

func _threader_read_item_file(parent_folder: String, file_name: String) -> StringName:
	var file: FileUtils = FileUtils.new(parent_folder)
	print(file)
	var content: String = file.read(file_name)
	var definition:ItemDefinition = ItemDefinition.parse(ConstantManager.CORE_MOD_NAME, content)
	ItemRegistry.get_self().add_item(definition)
	return definition.get_id()

func load() -> void:
	super.load()
