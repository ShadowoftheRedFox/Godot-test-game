## Instance of an item, with the general methods associated.
class_name ItemInstance extends ElementInstance

func get_definition() -> ItemDefinition:
	return ItemRegistry.get_self().get_item(get_definition_id())

func pick_up(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.PICKED_UP, data)

func drop(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.DROPPED, data)

func use(data: Dictionary = {}) -> void:
	call_behaviors(ItemDefinition.Interaction.USED, data)
