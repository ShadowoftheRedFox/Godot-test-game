## Adds functionnality to a fluid. Called everytime a fluid is used.
@abstract class_name FluidBehavior extends ElementBehavior

## Called everytime a fluid is used or interacted with, described by the `interaction`.
## Additional data can be added via the `data` dictionary.
@abstract func behave(fluid_definition_id: StringName, interaction: FluidDefinition.Interaction = FluidDefinition.Interaction.UNKNOWN, data: Dictionary = {}) -> void
