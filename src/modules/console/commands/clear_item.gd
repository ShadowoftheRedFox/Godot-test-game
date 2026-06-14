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
	if line.length() == 0:
		Global.player.inventory.clear()
		trace("Cleared inventory")
		return

	# get parameters if any
	var parameters: PackedStringArray = line.split(" ", false, 2)

	# fetch the item name
	var item_name: StringName = StringName(parameters[0])
	if !Global.CONST.ITEM_NAMES.has(item_name):
		error("Unknown item called \"" + item_name + "\"")
		return

	# fetch the amount
	var amount: int = -1
	if parameters.size() >= 2:
		if !parameters[1].is_valid_int():
			help("The amount given is not a valid number.")
			return
		amount = parameters[1].to_int()
		if amount <= 0:
			error("Invalid amount given. Expected 1 or more, got " + parameters[1])
			return

	# we have out item and our amount, get out item resource
	var item: InventoryItem = ResourceLoader.load(Global.CONST.ITEM_FOLDER + item_name + ".tres", "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	if item == null:
		error("Failed to load item.")
		return

	var result: int = Global.player.inventory.remove_item(item, amount)
	trace("Cleared " + ('all' if amount == -1 else str(amount - result)) + " " + item.item_name + " from inventory")

func autocomplete(partial: String) -> bool:
	if super.autocomplete(partial):
		return true

	# at this point, partial should only be the parameters
	var words: PackedStringArray = partial.split(" ", true, 1)
	var size: int = words.size()
	var word: String = words[0]
	# if word is the last word in the line, try to autocomplete it with an item name
	if size == 1:
		# array of item names that match the autocompletion
		var candidates: Array[String] = []
		for item_name: StringName in Global.CONST.ITEM_NAMES:
			if item_name.begins_with(word):
				candidates.push_back(item_name)

		if candidates.size() == 0:
			# show all items availables
			info(", ".join(Global.CONST.ITEM_NAMES))
			return true
		elif candidates.size() == 1:
			# call complete
			Global.CONSOLE.Complete.emit(candidates[0])
		else:
			# join results and propose values
			info(", ".join(candidates))
		return true

	# length is > 1, so we're trying to autocomplete a number, so just end here
	return true
