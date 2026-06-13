class_name CommandGive extends ConsoleCommand

func _init() -> void:
	name = "give"
	summary = "Give items to the player."
	description = "Give items to the player.
	Usage: item_name [amount:int]
	\titem_name: A valid item name.
	\tamount: Optional. The amount of item to give. Must be greater than 0."

func _execute_parameters(line: String) -> void:
	# get parameters
	var parameters: PackedStringArray = line.split(" ", false, 2)

	if len(parameters) < 1:
		help("Missing item_name")
		return

	# fetch the item name
	var item_name: StringName = StringName(parameters[0])
	if !GameState.CONST.ITEM_NAMES.has(item_name):
		error("Unknown item called \"" + item_name + "\"")
		return

	# fetch the amount
	var amount: int = 1
	if len(parameters) >= 2:
		if !parameters[1].is_valid_int():
			help("The amount given is not a valid number.")
			return
		amount = parameters[1].to_int()
		if amount <= 0:
			error("Invalid amount given. Expected 1 or more, got " + parameters[1] + "")
			return

	# we have out item and our amount, get out item resource
	var item: InventoryItem = ResourceLoader.load(GameState.CONST.ITEM_FOLDER + item_name + ".tres", "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	if item == null:
		error("Failedtoloaditem.")
		return

	#BUG can't add more than max_items_per_slot in one slot
	GameState.player.inventory.add_item(item, amount)
	# TODO print the internal state of the inventory after
