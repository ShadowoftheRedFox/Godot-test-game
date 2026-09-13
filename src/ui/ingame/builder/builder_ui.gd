class_name BuildingMenuList extends MarginContainer

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

func _load_building(building_name: String) -> Building:
    return ResourceLoader.load(Global.CONST.BUILDING_FOLDER + building_name + ".tres", "Building", ResourceLoader.CACHE_MODE_REUSE)

func _category_name(category: Building.BuildingCategory) -> String:
    match category:
        Building.BuildingCategory.UNCATEGORIZED:
            return "Uncategorized"
        Building.BuildingCategory.PRODUCTION:
            return "Production"
        Building.BuildingCategory.STORAGE:
            return "Storage"
        Building.BuildingCategory.BUILDING:
            return "Building"
        Building.BuildingCategory.DECORATION:
            return "Decoration"
        Building.BuildingCategory.TRANSPORTATION:
            return "Transportation"
        _:
            return "Unknown"

## Create teh menus
func _setup_menus() -> void:
    for n: String in Global.CONST.BUILDING_NAMES:
        _setup_menu(n)

    _finalize_menus()

## Create the menu for the given item
func _setup_menu(b_name: String) -> void:
    var building: Building = _load_building(b_name)
    if building == null:
        printerr("Couldn't load building ", b_name)
        return

    _setup_category(building)
    _setup_group(building)
    _setup_slot(b_name, building)

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
func _setup_category(building: Building) -> void:
    var c_name: String = _category_name(building.building_category)
    if _category_menu_nodes.has(c_name):
        return

    var bb: Button = Button.new()
    bb.text = c_name
    bb.name = str(building.building_category)
    _category_menu_nodes.set(c_name, bb)

    var bc: Control = Control.new()
    bc.name = str(building.building_category)
    bc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bc.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _category_content_nodes.set(c_name, bc)

    bb.pressed.connect(_show_category.bind(building.building_category))

## Setup the group for the following building
func _setup_group(building: Building) -> void:
    if _group_nodes.has(building.building_group):
        return

    var gn: FoldableContainer = FoldableContainer.new()
    gn.title = building.building_group.capitalize()
    gn.set_anchors_preset(Control.PRESET_TOP_WIDE)
    _group_nodes.set(building.building_group, gn)

    var bc: Control = _category_content_nodes.get(_category_name(building.building_category))
    bc.add_child(gn)

## Setup the slot for the following building
func _setup_slot(b_name: String, building: Building) -> void:
    # TODO reuse the slot display for the building
    if item_slots.has(b_name):
        return

    var b: Button = Button.new()
    b.text = b_name
    item_slots.set(b_name, b)

    var gn: FoldableContainer = _group_nodes.get(building.building_group)
    gn.add_child(b)


## Hides all other category other then the targeted one
func _show_category(category: Building.BuildingCategory) -> void:
    var c_name: String = _category_name(category)
    for c: String in _category_content_nodes.keys():
        var ctrl: Control = _category_content_nodes.get(c)
        if c != c_name:
            ctrl.hide()
        else:
            ctrl.show()
