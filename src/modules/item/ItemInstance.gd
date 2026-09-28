## Instance of an item, with the general methods associated.
class_name ItemInstance extends RefCounted

var _definition_id: StringName = ""

func _init() -> void:
	pick_up()

func get_definition_id() -> StringName:
	return _definition_id

func get_definition() -> ItemDefinition:
	return ItemRegistry.get_self().get_item(_definition_id)

func call_behaviors(interaction: ItemDefinition.Interaction = ItemDefinition.Interaction.UNKNOWN, data: Dictionary = {}) -> void:
	for b: ItemBehavior in get_definition().get_behaviors():
		b.behave(get_definition_id(), interaction, data)

func pick_up(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.PICKED_UP, data)

func drop(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.DROPPED, data)

func use(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.USED, data)
