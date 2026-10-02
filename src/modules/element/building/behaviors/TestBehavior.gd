class_name TestBuildingBehavior extends BuildingBehavior

static func factory(_data: Dictionary = {}) -> BuildingBehavior:
	return TestBuildingBehavior.new()

func get_factory() -> Callable:
	return factory

func get_behavior_name() -> StringName:
	return &"TestBuildingBehavior"

func behave(building_definition_id: StringName, interaction: BuildingDefinition.Interaction = BuildingDefinition.Interaction.UNKNOWN, _data: Dictionary = {}) -> void:
	print("Test behaved on %s, for interaction %d" % [building_definition_id, interaction])

func _to_json() -> String:
	return "{}"
