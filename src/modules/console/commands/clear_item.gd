class_name CommandClearItem extends ConsoleCommand

func _init() -> void:
	name = "clear"
	summary = "Remove items from the player."
	description = "Remove items from the player.
	Usage: [item_name] [amount:int]
	\tNo parameters: Clear the whole inventory.
	\titem_name: A valid item name.
	\tamount: Optional. The amount of item to remove. Must be greater than 0."

	requirements = RequirementsFlags.PRIVILEGED

func _execute_parameters(line: String) -> void:
	if len(line) == 0:
		GameState.player.inventory.clear()
		return

	# get parameters if any
	var parameters: PackedStringArray = line.split(" ", false, 2)

	# fetch the item name
	var item_name: StringName = StringName(parameters[0])
	if !GameState.CONST.ITEM_NAMES.has(item_name):
		error("Unknown item called \"" + item_name + "\"")
		return

	# fetch the amount
	var amount: int = -1
	if len(parameters) >= 2:
		if !parameters[1].is_valid_int():
			help("The amount given is not a valid number.")
			return
		amount = parameters[1].to_int()
		if amount <= 0:
			error("Invalid amount given. Expected 1 or more, got " + parameters[1])
			return

	# we have out item and our amount, get out item resource
	var item: InventoryItem = ResourceLoader.load(GameState.CONST.ITEM_FOLDER + item_name + ".tres", "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	if item == null:
		error("Failed to load item.")
		return

	GameState.player.inventory.remove_item(item, amount)

# TEST to test
