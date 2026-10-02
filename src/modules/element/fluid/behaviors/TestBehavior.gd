class_name TestFluidBehavior extends FluidBehavior

static func factory(_data: Dictionary = {}) -> FluidBehavior:
	return TestFluidBehavior.new()

func get_factory() -> Callable:
	return factory

func get_behavior_name() -> StringName:
	return &"TestFluidBehavior"

func behave(fluid_definition_id: StringName, interaction: FluidDefinition.Interaction = FluidDefinition.Interaction.UNKNOWN, _data: Dictionary = {}) -> void:
	print("Test behaved on %s, for interaction %d" % [fluid_definition_id, interaction])

func _to_json() -> String:
	return "{}"
