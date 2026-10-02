## Adds functionnality to a building. Called everytime a building is used.
@abstract class_name BuildingBehavior extends ElementBehavior

## Called everytime a building is used or interacted with, described by the `interaction`.
## Additional data can be added via the `data` dictionary.
@abstract func behave(building_definition_id: StringName, interaction: BuildingDefinition.Interaction = BuildingDefinition.Interaction.UNKNOWN, data: Dictionary = {}) -> void
