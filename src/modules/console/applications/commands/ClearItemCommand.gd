class_name CommandClearItem extends Command

func configure() -> void:
	name = "clear"
	description = "Clear items to the player."
	help = "Clear items to the player."

	requirements = RequirementsFlags.PRIVILEGED

func get_definition(_caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new("item", "The name of the item(s) to clear.", CommandInputArgument.REQUIRED, Global.CONST.ITEM_NAMES, null, CommandInputArgument.STRING),
		CommandInputArgument.new("amout", "The amount of items to clear. Must be positive", CommandInputArgument.OPTIONAL, null, null, CommandInputArgument.INT),
	])

func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var item_name: String = input.get_argument("item").get_value()
	var amount: int = input.get_argument("amount").get_value()

	if !Global.CONST.ITEM_NAMES.has(item_name):
		caller.error("Unknown item called \"" + item_name + "\"")
		return false

	if amount <= 0:
		caller.error("Invalid amount. Expected 1 or more, got " + str(amount))
		return false

	# we have out item and our amount, get out item resource
	var item: InventoryItem = ResourceLoader.load(Global.CONST.ITEM_FOLDER + item_name + ".tres", "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	if item == null:
		caller.error("Could not load item " + item_name)
		return false

	var result: int = Global.player.inventory.remove_item(item, amount)
	caller.print("Removed " + str(amount - result) + " " + item.item_display_name)
	return true
