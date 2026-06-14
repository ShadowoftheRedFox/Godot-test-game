class_name CommandTime extends ConsoleCommand

class CommandTimeSet extends ConsoleCommand:
	func _init() -> void:
		name = "set"
		summary = "Set the time of the day."
		description = "Set the time of the day.
		Usage: amount:int
		\tamount: The time of the day, between 0000 and 2399. Higher values are wrapped around."

	func _execute_parameters(line: String) -> void:
		if line.length() == 0:
			help()
			return

		if !line.is_valid_int():
			error("The given amount is not a valid number.")
			return

		var amount: int = line.to_int() % Global.CONST.DAY_LENGTH
		# TODO change day time

class CommandTimeAdd extends ConsoleCommand:
	func _init() -> void:
		name = "add"
		summary = "Add to the time of the day."
		description = "Add to the time of the day.
		Usage: amount:int
		\tamount: The time to add, between 0000 and 2399. Higher values are wrapped around."

	func _execute_parameters(line: String) -> void:
		if line.length() == 0:
			help()
			return

		if !line.is_valid_int():
			error("The given amount is not a valid number.")
			return

		var amount: int = line.to_int() % Global.CONST.DAY_LENGTH
		# TODO change day time

class CommandTimeRemove extends ConsoleCommand:
	func _init() -> void:
		name = "remove"
		summary = "Remove to the time of the day."
		description = "Remove to the time of the day.
		Usage: amount:int
		\tamount: The time to remove, between 0000 and 2399. Higher values are wrapped around."

	func _execute_parameters(line: String) -> void:
		if line.length() == 0:
			help()
			return

		if !line.is_valid_int():
			error("The given amount is not a valid number.")
			return

		var amount: int = line.to_int() % Global.CONST.DAY_LENGTH
		# TODO change day time

func _init() -> void:
	name = "time"
	summary = "Change the time of the day."
	description = "Change the time of the day.
	Usage: <set|add|remove> amount:int"

	register(CommandTimeSet.new())
	register(CommandTimeAdd.new())
	register(CommandTimeRemove.new())

func _execute_parameters(_line: String) -> void:
	help()
