## Adds functionnality to an item. Called everytime an item is used.
@abstract class_name ItemBehavior extends ElementBehavior

## Called everytime an item is used or interacted with, described by the `interaction`.
## Additional data can be added via the `data` dictionary.
@abstract func behave(item_definition_id: StringName, interaction: ItemDefinition.Interaction = ItemDefinition.Interaction.UNKNOWN, data: Dictionary = {}) -> void
