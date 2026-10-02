class_name TestItemBehavior extends ItemBehavior

static func factory(_data: Dictionary = {}) -> ItemBehavior:
	return TestItemBehavior.new()

func get_factory() -> Callable:
	return factory

func get_behavior_name() -> StringName:
	return &"TestItemBehavior"

func behave(item_definition_id: StringName, interaction: ItemDefinition.Interaction = ItemDefinition.Interaction.UNKNOWN, _data: Dictionary = {}) -> void:
	print("Test behaved on %s, for interaction %d" % [item_definition_id, interaction])

func _to_json() -> String:
	return "{}"
