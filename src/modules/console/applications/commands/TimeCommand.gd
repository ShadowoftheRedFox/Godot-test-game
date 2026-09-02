class_name CommandTime extends Command

const DAY_PARTS: PackedStringArray = ["day", "night", "sunset", "sunrise", "noon", "midnight"]
const ACTIONS: PackedStringArray = ["set", "stop", "start", "display", "length"]

func configure() -> void:
	name = "time"
	description = "Manipulate the time of the day."

	requirements = RequirementsFlags.PRIVILEGED
	usages.append_array([
		"time set day",
		"time set night",
		"time set 0",
		"time set 1200",
		"time stop",
		"time start",
		"time display",
		"time length 2400",
	])

func get_definition(_caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new(
			"action",
			"The action to do",
			CommandInputArgument.REQUIRED,
			ACTIONS,
			null,
			CommandInputArgument.STRING
		),
		CommandInputArgument.new(
			"value",
			"The value to apply to the action",
			CommandInputArgument.OPTIONAL,
			DAY_PARTS,
			null,
			CommandInputArgument.STRING
		),
	])

func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var action: String = input.get_argument("action").get_value()
	var value: String = input.get_argument("value").get_value()

	match action:
		"set" when value.is_valid_int():
			_set_time(caller, int(value))
			return true
		"set" when DAY_PARTS.has(value):
			_set_time_part(caller, value)
			return true
		"set":
			caller.error("Unable to set the time of the day, value is either an integer or one of: " + ", ".join(DAY_PARTS) + ".")
			return false
		"stop":
			Global.environment.day_night_cycle_enabled = false
			caller.print("The sun will never rise again!")
			return true
		"start":
			Global.environment.day_night_cycle_enabled = true
			caller.print("The sun can rise again!")
			return true
		"display":
			_display_time(caller)
			return true
		"length" when value.is_empty() || value.is_valid_int():
			_set_day_length(caller, int(value) if value.is_valid_int() else EnvironmentController.DAY_LENGTH)
			return true
		"length":
			caller.error("Unable to set the length of the day, value is an integer with the length of the day in seconds.")
			return false
		_:
			caller.error("Unknown action \"" + action + "\"")
			return false

func _display_time(caller: CommandApplication) -> void:
	# TODO says the days that passed, month... ?
	var time: float = Global.environment.get_time()

	var hours: int = int(time / float(EnvironmentController.DAY_HOURS_LENGTH))
	time -= hours * EnvironmentController.DAY_HOURS_LENGTH
	var minutes: int = int(time / float(EnvironmentController.DAY_HOURS_LENGTH) * 60)

	var h: String = str(hours).pad_zeros(2)
	var m: String = str(minutes).pad_zeros(2)

	caller.print("Time is: " + h + ":" + m)

func _set_time_part(caller: CommandApplication, day_part: String) -> void:
	var time: int = 0
	match day_part:
		"day":
			time = 6000
		"night":
			time = 2200
		"sunset":
			time = 2000
		"sunrise":
			time = 8000
		"noon":
			time = 1200
		"midnight":
			time = 0

	_set_time(caller, time)

func _set_time(caller: CommandApplication, time: int) -> void:
	# make sure the time is valid, between 0 and 2399
	time = time % EnvironmentController.DAY_LENGTH
	if time < 0:
		time += EnvironmentController.DAY_LENGTH
	Global.environment.set_time(time)
	caller.print("Set time to " + str(time))

func _set_day_length(caller: CommandApplication, length: int) -> void:
	Global.environment.set_day_length(length)
	caller.print("The day length is now " + str(length) + " seconds.")
