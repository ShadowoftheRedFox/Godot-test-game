class_name CommandClearItem extends Command

func configure() -> void:
	name = "clear"
	description = "Clear items to the player."
	help = "Clear items to the player."

	requirements = RequirementsFlags.PRIVILEGED

func get_definition(_caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new("item", "The name of the item(s) to clear.", CommandInputArgument.REQUIRED, ItemRegistry.get_self().get_item_name_list(), null, CommandInputArgument.STRING),
		CommandInputArgument.new("amout", "The amount of items to clear. Must be positive", CommandInputArgument.OPTIONAL, null, null, CommandInputArgument.INT),
	])

func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var item_name: String = input.get_argument("item").get_value()
	var amount: int = input.get_argument("amount").get_value()

	if !ItemRegistry.get_self().has_item_name(item_name):
		caller.error("Unknown item called \"" + item_name + "\"")
		return false

	if amount <= 0:
		caller.error("Invalid amount. Expected 1 or more, got " + str(amount))
		return false

	var result: int = Global.player.inventory.remove_item(item_name, amount)
	caller.print("Removed " + str(amount - result) + " " + item_name)
	return true
