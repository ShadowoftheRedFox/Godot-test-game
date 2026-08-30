class_name CommandGiveItem extends Command

func configure() -> void:
	name = "give"
	description = "Give items to the player."
	help = "Give items to the player.
	Usage: item_name [amount:int]
	\titem_name: A valid item name.
	\tamount: Optional. The amount of item to give. Must be greater than 0."

	requirements = RequirementsFlags.PRIVILEGED

func get_definition(_caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new("item", "The name of the item to give", CommandInputArgument.REQUIRED, Global.CONST.ITEM_NAMES, null, CommandInputArgument.STRING),
		CommandInputArgument.new("amount", "The amount of item to give", CommandInputArgument.OPTIONAL, null, 1, CommandInputArgument.INT),
	])

func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var item_name: String = input.get_argument("item").get_value()
	var amount: int = input.get_argument("amount").get_value()

	if !Global.CONST.ITEM_NAMES.has(item_name):
		caller.output.emit("Unknown item called \"" + item_name + "\"")
		return false

	if amount <= 0:
		caller.output.emit("Invalid amount. Expected 1 or more, got " + str(amount))
		return false

	# we have out item and our amount, get out item resource
	var item: InventoryItem = ResourceLoader.load(Global.CONST.ITEM_FOLDER + item_name + ".tres", "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	if item == null:
		caller.output.emit("Could not load item " + item_name)
		return false

	var result: int = Global.player.inventory.add_item(item, amount)
	caller.output.emit("Given " + str(amount - result) + " " + item.item_display_name)
	return true
