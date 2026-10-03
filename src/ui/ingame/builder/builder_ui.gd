class_name BuildingMenuList extends UIMenu

@onready var menu_list: VBoxContainer = %MenuList
@onready var content_list: VBoxContainer = %ContentList

## References from the category name to the button of this category
var _category_menu_nodes: Dictionary[String, Button] = {}
## References from the category to the content node containing the group nodes
var _category_content_nodes: Dictionary[String, Control] = {}
## Group name to the foldable container of that group
var _group_nodes: Dictionary[String, FoldableContainer] = {}
## Link an item to it's slot
var item_slots: Dictionary[String, Button] = {}

func _ready() -> void:
	_setup_menus()

func _category_name(category: BuildingDefinition.Category) -> String:
	var keys: Array = BuildingDefinition.Category.keys()
	if category >= keys.size() || category < 0:
		return "Unknown"

	return keys[category]

## Create the menus.
func _setup_menus() -> void:
	for building_name: StringName in BuildingRegistry.get_self().get_building_name_list():
		var building: BuildingDefinition = BuildingRegistry.get_self().get_building(building_name)
		_setup_category(building)
		_setup_group(building)
		_setup_slot(building)

	_finalize_menus()

## Add the menus to the tree.
func _finalize_menus() -> void:
	# add the category in name order
	var category_names: Array[String] = _category_menu_nodes.keys()
	category_names.sort()

	for c: String in category_names:
		var category: Button = _category_menu_nodes.get(c)
		menu_list.add_child(category)
		var content: Control = _category_content_nodes.get(c)
		content_list.add_child(content)

		# sort the content's children to have the group ordered by name
		var children: Array[Node] = content_list.get_children()
		children.sort_custom(func(a: FoldableContainer, b: FoldableContainer) -> bool: return a.title < b.title)
		for i: int in range(children.size()):
			content_list.move_child(children[i], i)

## Setup the category for the following building
func _setup_category(building: BuildingDefinition) -> void:
	var c_name: String = _category_name(building._category)
	# skip if the button already exists
	if _category_menu_nodes.has(c_name):
		return

	# setup the button to display the categor content
	var bb: Button = Button.new()
	bb.text = c_name.capitalize()
	_category_menu_nodes.set(c_name, bb)

	# setup the category content
	var bc: Control = Control.new()
	bc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_category_content_nodes.set(c_name, bc)

	bb.pressed.connect(_show_category.bind(building._category))

## Setup the group for the following building
func _setup_group(building: BuildingDefinition) -> void:
	# get a correct group name
	var group_name: String = "Ungrouped" if Utils.is_blank(building._group) else building._group.capitalize()

	# skip if the group container already exists
	if _group_nodes.has(group_name):
		return

	# create the group container
	var gn: FoldableContainer = FoldableContainer.new()
	gn.title = group_name
	gn.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_group_nodes.set(_category_name(building._category), gn)

	var bc: Control = _category_content_nodes.get(_category_name(building._category))
	bc.add_child(gn)

## Setup the slot for the following building
func _setup_slot(building: BuildingDefinition) -> void:
	# TODO reuse the slot display for the building
	if item_slots.has(building.get_id()):
		return

	var b: Button = Button.new()
	b.text = building.get_display_name()
	item_slots.set(building.get_id(), b)

	var gn: FoldableContainer = _group_nodes.get(_category_name(building._category))
	gn.add_child(b)

## Hides all other category other then the targeted one
func _show_category(category: BuildingDefinition.Category) -> void:
	var c_name: String = _category_name(category)
	for c: String in _category_content_nodes.keys():
		var ctrl: Control = _category_content_nodes.get(c)
		if c != c_name:
			ctrl.hide()
		else:
			ctrl.show()
