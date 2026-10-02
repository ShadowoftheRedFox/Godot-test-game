## Instance of a building, with the general methods associated.
class_name BuildingInstance extends ElementInstance

func get_definition() -> BuildingDefinition:
	return BuildingRegistry.get_self().get_building(get_definition_id())
