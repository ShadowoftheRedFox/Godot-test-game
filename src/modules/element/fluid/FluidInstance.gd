## Instance of a fluid, with the general methods associated.
class_name FluidInstance extends ElementInstance

func get_definition() -> FluidDefinition:
	return FluidRegistry.get_self().get_fluid(get_definition_id())
